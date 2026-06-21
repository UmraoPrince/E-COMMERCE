package com.ecommerce.servlet;

import com.ecommerce.dao.UserDAO;
import com.ecommerce.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO = new UserDAO();
    private com.ecommerce.dao.AuditLogDAO auditLogDAO = new com.ecommerce.dao.AuditLogDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("login".equals(action)) {
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            
            if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
                request.setAttribute("error", "Email and Password are required");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            // Check if there is an active unverified registration session for this email
            HttpSession tempSession = request.getSession(false);
            if (tempSession != null && tempSession.getAttribute("tempUser") != null) {
                User tempUser = (User) tempSession.getAttribute("tempUser");
                if (tempUser.getEmail().equalsIgnoreCase(email.trim())) {
                    request.setAttribute("error", "Please verify your email before logging in.");
                    request.getRequestDispatcher("register.jsp").forward(request, response);
                    return;
                }
            }

            User user = userDAO.loginUser(email.trim(), password);
            
            if (user != null) {
                if (!user.isVerified()) {
                    auditLogDAO.logAction("LOGIN_UNVERIFIED: " + email, email);
                    request.setAttribute("error", "Your account is not verified. Please register and verify your email first.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }

                HttpSession session = request.getSession(true);
                session.setAttribute("user", user);
                // Regenerate session ID to prevent Session Fixation attacks
                session.setAttribute("csrfToken", UUIDRandomToken()); // Refresh CSRF token on login
                auditLogDAO.logAction("LOGIN_SUCCESS: " + email, email);
                
                if ("ADMIN".equals(user.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                } else {
                    response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
                }
            } else {
                auditLogDAO.logAction("LOGIN_FAIL: " + email, email);
                request.setAttribute("error", "Invalid email or password");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } else if ("updateProfile".equals(action)) {
            // Check if user is logged in
            HttpSession session = request.getSession(false);
            User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            String name = request.getParameter("name");
            String mobile = request.getParameter("mobile");
            String address = request.getParameter("address");

            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Name cannot be empty");
                request.getRequestDispatcher("dashboard.jsp").forward(request, response); // Profile resides in dashboard panels
                return;
            }

            currentUser.setName(name.trim());
            currentUser.setMobile(mobile != null ? mobile.trim() : null);
            currentUser.setAddress(address != null ? address.trim() : null);

            if (userDAO.updateUserProfile(currentUser)) {
                session.setAttribute("user", currentUser); // update session object
                auditLogDAO.logAction("PROFILE_UPDATE: " + currentUser.getEmail(), currentUser.getEmail());
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp?profileSuccess=1");
            } else {
                request.setAttribute("error", "Failed to update profile");
                request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            }
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            User currentUser = (User) session.getAttribute("user");
            if (currentUser != null) {
                auditLogDAO.logAction("LOGOUT: " + currentUser.getEmail(), currentUser.getEmail());
            }
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/login.jsp?logout=1");
    }

    private String UUIDRandomToken() {
        return java.util.UUID.randomUUID().toString();
    }
}
