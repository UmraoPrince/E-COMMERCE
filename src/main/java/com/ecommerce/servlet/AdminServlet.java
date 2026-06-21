package com.ecommerce.servlet;

import com.ecommerce.dao.OrderDAO;
import com.ecommerce.dao.ProductDAO;
import com.ecommerce.dao.UserDAO;
import com.ecommerce.model.Order;
import com.ecommerce.model.Product;
import com.ecommerce.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/admin/dashboard", "/admin/orders", "/admin/users"})
public class AdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO = new UserDAO();
    private ProductDAO productDAO = new ProductDAO();
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String servletPath = request.getServletPath();

        if ("/admin/dashboard".equals(servletPath)) {
            // 1. Fetch dashboard metrics
            int totalUsers = userDAO.getTotalUsersCount();
            int totalProducts = productDAO.getTotalProductsCountAll();
            int totalOrders = orderDAO.getTotalOrdersCount();
            BigDecimal revenue = orderDAO.getTotalRevenue();
            List<Product> lowStockProducts = productDAO.getLowStockProducts(5); // Stock <= 5

            // Put in a map to match ${stats.totalUsers} format in user's JSP code
            Map<String, Object> stats = new HashMap<>();
            stats.put("totalUsers", totalUsers);
            stats.put("totalProducts", totalProducts);
            stats.put("totalOrders", totalOrders);
            stats.put("revenue", revenue);

            request.setAttribute("stats", stats);
            request.setAttribute("lowStockProducts", lowStockProducts);
            
            // Fetch simulated payment information for admin overview
            Map<String, Object> payStats = orderDAO.getPaymentStats();
            List<com.ecommerce.model.Payment> paymentHistory = orderDAO.getPaymentHistory();
            request.setAttribute("payStats", payStats);
            request.setAttribute("paymentHistory", paymentHistory);

            // Forward to dashboard JSP
            request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);

        } else if ("/admin/orders".equals(servletPath)) {
            // 2. Fetch all orders
            List<Order> orders = orderDAO.getAllOrders();
            request.setAttribute("orders", orders);
            request.getRequestDispatcher("/admin/orders.jsp").forward(request, response);

        } else if ("/admin/users".equals(servletPath)) {
            // 3. Fetch all users
            List<User> users = userDAO.getAllUsers();
            request.setAttribute("users", users);
            request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Redirect POST requests to GET dashboard
        doGet(request, response);
    }
}
