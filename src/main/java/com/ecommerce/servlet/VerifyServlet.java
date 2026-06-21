package com.ecommerce.servlet;

import com.ecommerce.dao.AuditLogDAO;
import com.ecommerce.dao.UserDAO;
import com.ecommerce.model.User;
import org.json.simple.JSONObject;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/verify")
public class VerifyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO = new UserDAO();
    private AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();

        try {
            String enteredOtp = request.getParameter("otp");
            if (enteredOtp == null || enteredOtp.trim().isEmpty()) {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "OTP is required.");
                out.print(jsonResponse.toString());
                return;
            }

            enteredOtp = enteredOtp.trim();

            HttpSession session = request.getSession(false);
            if (session == null || 
                session.getAttribute("otp") == null || 
                session.getAttribute("tempUser") == null) {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "No active verification session found. Please register again.");
                out.print(jsonResponse.toString());
                return;
            }

            String sessionOtp = (String) session.getAttribute("otp");
            Long otpTime = (Long) session.getAttribute("otp_time");
            User tempUser = (User) session.getAttribute("tempUser");

            // Check if OTP is expired (5 minutes timeout)
            long elapsed = System.currentTimeMillis() - otpTime;
            if (elapsed > 5 * 60 * 1000) {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "OTP has expired. Please click resend to get a new code.");
                out.print(jsonResponse.toString());
                return;
            }

            // Verify OTP
            if (sessionOtp.equals(enteredOtp)) {
                tempUser.setVerified(true);
                // Register user in the database
                if (userDAO.registerUser(tempUser)) {
                    // Log success
                    auditLogDAO.logAction("REGISTER_OTP_SUCCESS: " + tempUser.getEmail(), tempUser.getEmail());

                    // Clear OTP session data
                    session.removeAttribute("otp");
                    session.removeAttribute("otp_time");
                    session.removeAttribute("tempUser");

                    jsonResponse.put("status", "success");
                    jsonResponse.put("message", "Email Verified & Account Created successfully!");
                } else {
                    jsonResponse.put("status", "error");
                    jsonResponse.put("message", "Failed to save user account. Please try again.");
                }
            } else {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Invalid OTP. Please enter the correct code.");
            }

            out.print(jsonResponse.toString());

        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "An unexpected error occurred: " + e.getMessage());
            out.print(jsonResponse.toString());
        } finally {
            out.flush();
        }
    }
}
