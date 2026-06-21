package com.ecommerce.servlet;

import com.ecommerce.dao.CartDAO;
import com.ecommerce.model.CartItem;
import com.ecommerce.model.User;
import org.json.simple.JSONObject;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CartDAO cartDAO = new CartDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject obj = new JSONObject();

        if (user == null) {
            // Send special status for AJAX to redirect to login
            obj.put("status", "login");
            obj.put("message", "Please login to manage cart");
            out.print(obj.toJSONString());
            out.flush();
            return;
        }

        String action = request.getParameter("action");
        String prodIdStr = request.getParameter("productId");
        
        if (action == null || prodIdStr == null) {
            obj.put("status", "error");
            obj.put("message", "Invalid parameters");
            out.print(obj.toJSONString());
            out.flush();
            return;
        }

        int productId = Integer.parseInt(prodIdStr);
        int userId = user.getUserId();
        boolean success = false;

        if ("add".equals(action)) {
            success = cartDAO.addToCart(userId, productId);
        } else if ("remove".equals(action)) {
            success = cartDAO.removeFromCart(userId, productId);
        } else if ("update".equals(action)) {
            String qtyStr = request.getParameter("quantity");
            if (qtyStr != null) {
                int qty = Integer.parseInt(qtyStr);
                success = cartDAO.updateCartQuantity(userId, productId, qty);
            }
        }

        // Calculate current total cart item quantity
        int cartCount = 0;
        List<CartItem> items = cartDAO.getCartItems(userId);
        for (CartItem item : items) {
            cartCount += item.getQuantity();
        }

        if (success) {
            obj.put("status", "success");
            obj.put("cartCount", cartCount);
        } else {
            obj.put("status", "error");
            obj.put("message", "Operation failed. Out of stock or invalid database query.");
        }
        
        out.print(obj.toJSONString());
        out.flush();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Simple endpoint to query current cart count (used dynamically by script when loading pages)
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject obj = new JSONObject();

        if (user == null) {
            obj.put("cartCount", 0);
        } else {
            int cartCount = 0;
            List<CartItem> items = cartDAO.getCartItems(user.getUserId());
            for (CartItem item : items) {
                cartCount += item.getQuantity();
            }
            obj.put("cartCount", cartCount);
        }
        
        out.print(obj.toJSONString());
        out.flush();
    }
}
