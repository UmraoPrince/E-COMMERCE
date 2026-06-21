package com.ecommerce.servlet;

import com.ecommerce.dao.OrderDAO;
import com.ecommerce.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/order")
public class OrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        int userId = user.getUserId();
        String userEmail = user.getEmail();
        com.ecommerce.dao.AuditLogDAO auditLogDAO = new com.ecommerce.dao.AuditLogDAO();

        if ("place".equals(action)) {
            String address = request.getParameter("address");
            String paymentMethod = request.getParameter("paymentMethod");
            
            if (address == null || address.trim().isEmpty()) {
                request.setAttribute("error", "Shipping address is required.");
                request.getRequestDispatcher("checkout.jsp").forward(request, response);
                return;
            }

            int orderId = orderDAO.placeOrder(userId, address.trim(), paymentMethod);
            if (orderId > 0) {
                auditLogDAO.logAction("ORDER_PLACED: User " + userEmail, userEmail);
                if ("ONLINE".equals(paymentMethod)) {
                    response.sendRedirect(request.getContextPath() + "/payment.jsp?orderId=" + orderId);
                } else {
                    response.sendRedirect(request.getContextPath() + "/order-success.jsp?orderId=" + orderId);
                }
            } else {
                request.setAttribute("error", "Order placement failed. Some items in your cart may have gone out of stock. Please check your cart items.");
                request.getRequestDispatcher("checkout.jsp").forward(request, response);
            }
        } else if ("cancel".equals(action)) {
            String orderIdStr = request.getParameter("orderId");
            if (orderIdStr != null) {
                int orderId = Integer.parseInt(orderIdStr);
                orderDAO.cancelOrder(orderId, userId);
                auditLogDAO.logAction("ORDER_CANCEL: ID " + orderId, userEmail);
            }
            response.sendRedirect(request.getContextPath() + "/orders.jsp");
        } else if ("updateStatus".equals(action)) {
            // Admin only action - check authorization
            if (!"ADMIN".equals(user.getRole())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Only administrators can update order status.");
                return;
            }

            String orderIdStr = request.getParameter("orderId");
            String status = request.getParameter("status");
            
            if (orderIdStr != null && status != null) {
                int orderId = Integer.parseInt(orderIdStr);
                orderDAO.updateOrderStatus(orderId, status);
                auditLogDAO.logAction("ORDER_STATUS_UPDATE: ID " + orderId + " to " + status, userEmail);
            }
            response.sendRedirect(request.getContextPath() + "/admin/orders");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Redirect GET requests to customer orders summary page
        response.sendRedirect(request.getContextPath() + "/orders.jsp");
    }
}
