package com.ecommerce.servlet;

import com.ecommerce.dao.OrderDAO;
import com.ecommerce.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/payment-callback")
public class PaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        String orderIdStr = request.getParameter("orderId");
        String paymentStatus = request.getParameter("status"); // SUCCESSFUL or FAILED

        if (orderIdStr == null || paymentStatus == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"Missing parameters\"}");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            String orderStatus = "SUCCESSFUL".equalsIgnoreCase(paymentStatus) ? "CONFIRMED" : "PENDING";
            
            boolean updated = orderDAO.updatePaymentAndOrderStatus(orderId, paymentStatus.toUpperCase(), orderStatus);
            
            response.setContentType("application/json");
            if (updated) {
                com.ecommerce.dao.AuditLogDAO auditLogDAO = new com.ecommerce.dao.AuditLogDAO();
                auditLogDAO.logAction("PAYMENT_SIMULATION: Order " + orderId + " payment " + paymentStatus.toUpperCase(), user.getEmail());
                response.getWriter().write("{\"success\":true}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Failed to update database\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid orderId\"}");
        }
    }
}
