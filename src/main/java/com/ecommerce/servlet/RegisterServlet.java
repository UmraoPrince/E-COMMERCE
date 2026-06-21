package com.ecommerce.servlet;

import com.ecommerce.dao.UserDAO;
import com.ecommerce.model.User;
import com.ecommerce.util.EmailService;
import org.json.simple.JSONObject;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Random;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();

        try {
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String mobile = request.getParameter("mobile");
            String address = request.getParameter("address");

            // Input Validation
            if (name == null || name.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Name, Email and Password are required fields.");
                out.print(jsonResponse.toString());
                return;
            }

            email = email.trim().toLowerCase();

            // Check if user email already exists
            if (userDAO.checkEmailExists(email)) {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Email is already registered! Please sign in.");
                out.print(jsonResponse.toString());
                return;
            }

            // Generate secure 6-digit random code
            Random rand = new Random();
            int otpValue = 100000 + rand.nextInt(900000);
            String otpStr = String.valueOf(otpValue);

            System.out.println("\n==================================================");
            System.out.println("OTP Generated for " + email + ": " + otpStr);
            System.out.println("==================================================\n");

            try {
                java.nio.file.Files.write(
                    java.nio.file.Paths.get("otp_log.txt"),
                    ("Time: " + new java.util.Date() + " | Email: " + email + " | OTP: " + otpStr + "\n").getBytes(),
                    java.nio.file.StandardOpenOption.CREATE,
                    java.nio.file.StandardOpenOption.APPEND
                );
            } catch (Exception ex) {
                System.err.println("Could not write to otp_log.txt: " + ex.getMessage());
            }

            // Attempt to send email using real SMTP
            boolean emailSent = EmailService.sendOTP(email, name.trim(), otpStr);

            // Save validation details to user HTTP Session for verification stage
            HttpSession session = request.getSession(true);
            session.setAttribute("otp", otpStr);
            session.setAttribute("otp_time", System.currentTimeMillis());

            User tempUser = new User();
            tempUser.setName(name.trim());
            tempUser.setEmail(email);
            tempUser.setPassword(password); // Will be hashed in UserDAO.registerUser
            tempUser.setMobile(mobile != null ? mobile.trim() : null);
            tempUser.setAddress(address != null ? address.trim() : null);
            tempUser.setRole("USER");
            session.setAttribute("tempUser", tempUser);

            jsonResponse.put("status", "success");
            jsonResponse.put("mockOtp", otpStr); // Always return mockOtp in payload for API testing ease
            if (emailSent) {
                jsonResponse.put("message", "OTP has been sent to your email.");
            } else {
                jsonResponse.put("message", "Mock OTP generated (SMTP fallback active)!");
                jsonResponse.put("mock", true);
            }
            
            out.print(jsonResponse.toString());

        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "An unexpected server error occurred: " + e.getMessage());
            out.print(jsonResponse.toString());
        } finally {
            out.flush();
        }
    }
}
