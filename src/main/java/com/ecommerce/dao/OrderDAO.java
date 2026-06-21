package com.ecommerce.dao;

import com.ecommerce.model.Order;
import com.ecommerce.model.OrderItem;
import com.ecommerce.util.DBUtil;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    public int placeOrder(int userId, String address, String paymentMethod) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false); // Start Transaction

            // 1. Get Cart Items and check stock/retrieve catalog price
            String cartSql = "SELECT ci.product_id, ci.quantity, p.price, p.stock FROM cart_items ci " +
                             "JOIN cart c ON ci.cart_id = c.cart_id " +
                             "JOIN products p ON ci.product_id = p.product_id " +
                             "WHERE c.user_id = ?";
            
            List<OrderItem> items = new ArrayList<>();
            BigDecimal totalAmount = BigDecimal.ZERO;
            
            try (PreparedStatement psCart = conn.prepareStatement(cartSql)) {
                psCart.setInt(1, userId);
                try (ResultSet rs = psCart.executeQuery()) {
                    while (rs.next()) {
                        int prodId = rs.getInt("product_id");
                        int qty = rs.getInt("quantity");
                        BigDecimal price = rs.getBigDecimal("price");
                        int stock = rs.getInt("stock");
                        
                        if (stock < qty) {
                            conn.rollback();
                            return 0; // Out of stock
                        }
                        
                        OrderItem item = new OrderItem();
                        item.setProductId(prodId);
                        item.setQuantity(qty);
                        item.setPrice(price);
                        items.add(item);
                        
                        totalAmount = totalAmount.add(price.multiply(new BigDecimal(qty)));
                    }
                }
            }

            if (items.isEmpty()) {
                conn.rollback();
                return 0; // Cart was empty
            }

            // 2. Create Order
            String initialOrderStatus = "COD".equals(paymentMethod) ? "CONFIRMED" : "PENDING";
            String orderSql = "INSERT INTO orders (user_id, total_amount, shipping_address, status) VALUES (?, ?, ?, ?)";
            int orderId = 0;
            try (PreparedStatement psOrder = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
                psOrder.setInt(1, userId);
                psOrder.setBigDecimal(2, totalAmount);
                psOrder.setString(3, address);
                psOrder.setString(4, initialOrderStatus);
                psOrder.executeUpdate();
                
                try (ResultSet keys = psOrder.getGeneratedKeys()) {
                    if (keys.next()) {
                        orderId = keys.getInt(1);
                    }
                }
            }

            if (orderId == 0) {
                conn.rollback();
                return 0;
            }

            // 3. Add Order Items & Update Inventory atomically
            String itemSql = "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";
            String updateStockSql = "UPDATE products SET stock = stock - ? WHERE product_id = ? AND stock >= ?";
            
            try (PreparedStatement psItem = conn.prepareStatement(itemSql);
                 PreparedStatement psStock = conn.prepareStatement(updateStockSql)) {
                
                for (OrderItem item : items) {
                    // Insert order item row with exact price fetched
                    psItem.setInt(1, orderId);
                    psItem.setInt(2, item.getProductId());
                    psItem.setInt(3, item.getQuantity());
                    psItem.setBigDecimal(4, item.getPrice());
                    psItem.addBatch();

                    // Concurrency-safe stock deduction
                    psStock.setInt(1, item.getQuantity());
                    psStock.setInt(2, item.getProductId());
                    psStock.setInt(3, item.getQuantity()); // Must have stock >= quantity
                    int rowsUpdated = psStock.executeUpdate();
                    
                    if (rowsUpdated == 0) {
                        // Double check fails - concurrent checkout bought the item. Rollback.
                        conn.rollback();
                        return 0;
                    }
                }
                psItem.executeBatch();
            }

            // 4. Create Payment Record
            String transactionId = "TXN" + new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date()) + String.format("%04d", (int)(Math.random() * 10000));
            String paySql = "INSERT INTO payments (order_id, payment_method, transaction_id, payment_status, amount) VALUES (?, ?, ?, 'PENDING', ?)";
            try (PreparedStatement psPay = conn.prepareStatement(paySql)) {
                psPay.setInt(1, orderId);
                psPay.setString(2, paymentMethod);
                psPay.setString(3, transactionId);
                psPay.setBigDecimal(4, totalAmount);
                psPay.executeUpdate();
            }

            // 5. Clear Cart Items (Database-agnostic delete query)
            String clearCartSql = "DELETE FROM cart_items WHERE cart_id = (SELECT cart_id FROM cart WHERE user_id = ?)";
            try (PreparedStatement psClear = conn.prepareStatement(clearCartSql)) {
                psClear.setInt(1, userId);
                psClear.executeUpdate();
            }

            conn.commit();
            return orderId;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return 0;
    }
    
    public List<Order> getUserOrders(int userId) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT o.*, p.payment_method, p.payment_status, p.transaction_id FROM orders o " +
                     "LEFT JOIN payments p ON o.order_id = p.order_id " +
                     "WHERE o.user_id = ? ORDER BY o.order_date DESC";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getInt("order_id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setTotalAmount(rs.getBigDecimal("total_amount"));
                    order.setOrderDate(rs.getTimestamp("order_date"));
                    order.setStatus(rs.getString("status"));
                    order.setShippingAddress(rs.getString("shipping_address"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    order.setPaymentStatus(rs.getString("payment_status"));
                    order.setTransactionId(rs.getString("transaction_id"));
                    orders.add(order);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }

    public Order getOrderById(int orderId) {
        String sql = "SELECT o.*, u.name as user_name, p.payment_method, p.payment_status, p.transaction_id FROM orders o " +
                     "LEFT JOIN users u ON o.user_id = u.user_id " +
                     "LEFT JOIN payments p ON o.order_id = p.order_id " +
                     "WHERE o.order_id = ?";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getInt("order_id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setUserName(rs.getString("user_name"));
                    order.setTotalAmount(rs.getBigDecimal("total_amount"));
                    order.setOrderDate(rs.getTimestamp("order_date"));
                    order.setStatus(rs.getString("status"));
                    order.setShippingAddress(rs.getString("shipping_address"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    order.setPaymentStatus(rs.getString("payment_status"));
                    order.setTransactionId(rs.getString("transaction_id"));
                    return order;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<OrderItem> getOrderItems(int orderId) {
        List<OrderItem> list = new ArrayList<>();
        String sql = "SELECT oi.*, p.product_name FROM order_items oi " +
                     "JOIN products p ON oi.product_id = p.product_id " +
                     "WHERE oi.order_id = ?";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setOrderItemId(rs.getInt("order_item_id"));
                    item.setOrderId(rs.getInt("order_id"));
                    item.setProductId(rs.getInt("product_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setPrice(rs.getBigDecimal("price"));
                    item.setProductName(rs.getString("product_name"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Order> getAllOrders() {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT o.*, u.name as user_name, p.payment_method, p.payment_status, p.transaction_id FROM orders o " +
                     "LEFT JOIN users u ON o.user_id = u.user_id " +
                     "LEFT JOIN payments p ON o.order_id = p.order_id " +
                     "ORDER BY o.order_date DESC";
        try (Connection conn = DBUtil.getConnection(); 
             Statement stmt = conn.createStatement(); 
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("order_id"));
                order.setUserId(rs.getInt("user_id"));
                order.setUserName(rs.getString("user_name"));
                order.setTotalAmount(rs.getBigDecimal("total_amount"));
                order.setOrderDate(rs.getTimestamp("order_date"));
                order.setStatus(rs.getString("status"));
                order.setShippingAddress(rs.getString("shipping_address"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setTransactionId(rs.getString("transaction_id"));
                orders.add(order);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }

    public boolean updateOrderStatus(int orderId, String status) {
        String sql = "UPDATE orders SET status = ? WHERE order_id = ?";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            
            // If order status is marked as DELIVERED, automatically mark payment status as SUCCESSFUL
            boolean success = ps.executeUpdate() > 0;
            if (success && "DELIVERED".equals(status)) {
                String paySql = "UPDATE payments SET payment_status = 'SUCCESSFUL' WHERE order_id = ?";
                try (PreparedStatement psPay = conn.prepareStatement(paySql)) {
                    psPay.setInt(1, orderId);
                    psPay.executeUpdate();
                }
            }
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePaymentAndOrderStatus(int orderId, String paymentStatus, String orderStatus) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);
            
            // 1. Update orders status
            String orderSql = "UPDATE orders SET status = ? WHERE order_id = ?";
            try (PreparedStatement psOrder = conn.prepareStatement(orderSql)) {
                psOrder.setString(1, orderStatus);
                psOrder.setInt(2, orderId);
                psOrder.executeUpdate();
            }
            
            // 2. Update payments status
            String paySql = "UPDATE payments SET payment_status = ? WHERE order_id = ?";
            try (PreparedStatement psPay = conn.prepareStatement(paySql)) {
                psPay.setString(1, paymentStatus);
                psPay.setInt(2, orderId);
                psPay.executeUpdate();
            }
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return false;
    }

    public List<com.ecommerce.model.Payment> getPaymentHistory() {
        List<com.ecommerce.model.Payment> list = new ArrayList<>();
        String sql = "SELECT p.*, u.name as user_name FROM payments p " +
                     "JOIN orders o ON p.order_id = o.order_id " +
                     "JOIN users u ON o.user_id = u.user_id " +
                     "ORDER BY p.payment_date DESC";
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                com.ecommerce.model.Payment payment = new com.ecommerce.model.Payment();
                payment.setPaymentId(rs.getInt("payment_id"));
                payment.setOrderId(rs.getInt("order_id"));
                payment.setPaymentMethod(rs.getString("payment_method"));
                payment.setTransactionId(rs.getString("transaction_id"));
                payment.setPaymentStatus(rs.getString("payment_status"));
                payment.setPaymentDate(rs.getTimestamp("payment_date"));
                payment.setAmount(rs.getBigDecimal("amount"));
                payment.setUserName(rs.getString("user_name"));
                list.add(payment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public java.util.Map<String, Object> getPaymentStats() {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        int total = 0, success = 0, failed = 0, pending = 0;
        String sql = "SELECT payment_status, COUNT(*) as cnt FROM payments GROUP BY payment_status";
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                String status = rs.getString("payment_status");
                int cnt = rs.getInt("cnt");
                if (status != null) {
                    status = status.toUpperCase();
                    if (status.contains("SUCCESS")) {
                        success += cnt;
                    } else if (status.contains("FAIL")) {
                        failed += cnt;
                    } else if (status.contains("PENDING")) {
                        pending += cnt;
                    }
                }
                total += cnt;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        stats.put("totalPayments", total);
        stats.put("successPayments", success);
        stats.put("failedPayments", failed);
        stats.put("pendingPayments", pending);
        return stats;
    }

    public boolean cancelOrder(int orderId, int userId) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // 1. Fetch order details to verify cancelability and get user ID
            String checkSql = "SELECT user_id, status FROM orders WHERE order_id = ?";
            String orderStatus = "";
            int orderOwnerId = 0;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        orderOwnerId = rs.getInt("user_id");
                        orderStatus = rs.getString("status");
                    }
                }
            }

            // Security check: must belong to user (or admin check bypassed by setting userId = -1)
            if (userId != -1 && orderOwnerId != userId) {
                conn.rollback();
                return false;
            }

            // Only PENDING and CONFIRMED orders can be cancelled
            if (!"PENDING".equals(orderStatus) && !"CONFIRMED".equals(orderStatus)) {
                conn.rollback();
                return false;
            }

            // 2. Set order status to CANCELLED
            String cancelSql = "UPDATE orders SET status = 'CANCELLED' WHERE order_id = ?";
            try (PreparedStatement psCancel = conn.prepareStatement(cancelSql)) {
                psCancel.setInt(1, orderId);
                psCancel.executeUpdate();
            }

            // 3. Restore inventory stocks
            String itemsSql = "SELECT product_id, quantity FROM order_items WHERE order_id = ?";
            String restoreStockSql = "UPDATE products SET stock = stock + ? WHERE product_id = ?";
            
            try (PreparedStatement psItems = conn.prepareStatement(itemsSql);
                 PreparedStatement psRestore = conn.prepareStatement(restoreStockSql)) {
                psItems.setInt(1, orderId);
                try (ResultSet rs = psItems.executeQuery()) {
                    while (rs.next()) {
                        int prodId = rs.getInt("product_id");
                        int qty = rs.getInt("quantity");
                        
                        psRestore.setInt(1, qty);
                        psRestore.setInt(2, prodId);
                        psRestore.executeUpdate();
                    }
                }
            }

            // 4. Update payment status to FAILED
            String paySql = "UPDATE payments SET payment_status = 'FAILED' WHERE order_id = ?";
            try (PreparedStatement psPay = conn.prepareStatement(paySql)) {
                psPay.setInt(1, orderId);
                psPay.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return false;
    }

    public BigDecimal getTotalRevenue() {
        String sql = "SELECT SUM(total_amount) FROM orders WHERE status != 'CANCELLED'";
        try (Connection conn = DBUtil.getConnection(); 
             Statement stmt = conn.createStatement(); 
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                BigDecimal sum = rs.getBigDecimal(1);
                return (sum != null) ? sum : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    public int getTotalOrdersCount() {
        String sql = "SELECT COUNT(*) FROM orders";
        try (Connection conn = DBUtil.getConnection(); 
             Statement stmt = conn.createStatement(); 
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
