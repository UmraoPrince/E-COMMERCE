package com.ecommerce.dao;

import com.ecommerce.model.CartItem;
import com.ecommerce.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAO {

    /**
     * Get or create a cart for a specific user and return its cart_id.
     */
    public int getOrCreateCartId(int userId) {
        String selectSql = "SELECT cart_id FROM cart WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cart_id");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // If not found, create one
        String insertSql = "INSERT INTO cart (user_id) VALUES (?)";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean addToCart(int userId, int productId) {
        int cartId = getOrCreateCartId(userId);
        if (cartId == 0) return false;

        // Check if item already exists in cart
        String checkSql = "SELECT cart_item_id, quantity FROM cart_items WHERE cart_id = ? AND product_id = ?";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, cartId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // Update quantity (+1)
                    int cartItemId = rs.getInt("cart_item_id");
                    int currentQty = rs.getInt("quantity");
                    String updateSql = "UPDATE cart_items SET quantity = ? WHERE cart_item_id = ?";
                    try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                        psUpdate.setInt(1, currentQty + 1);
                        psUpdate.setInt(2, cartItemId);
                        return psUpdate.executeUpdate() > 0;
                    }
                } else {
                    // Insert new item
                    String insertSql = "INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?, ?, 1)";
                    try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                        psInsert.setInt(1, cartId);
                        psInsert.setInt(2, productId);
                        return psInsert.executeUpdate() > 0;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean removeFromCart(int userId, int productId) {
        int cartId = getOrCreateCartId(userId);
        if (cartId == 0) return false;

        String sql = "DELETE FROM cart_items WHERE cart_id = ? AND product_id = ?";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCartQuantity(int userId, int productId, int quantity) {
        int cartId = getOrCreateCartId(userId);
        if (cartId == 0) return false;

        if (quantity <= 0) {
            return removeFromCart(userId, productId);
        }

        String sql = "UPDATE cart_items SET quantity = ? WHERE cart_id = ? AND product_id = ?";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, cartId);
            ps.setInt(3, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<CartItem> getCartItems(int userId) {
        List<CartItem> items = new ArrayList<>();
        String sql = "SELECT ci.cart_item_id, ci.cart_id, ci.product_id, ci.quantity, " +
                     "p.product_name, p.price, p.image, p.stock " +
                     "FROM cart_items ci " +
                     "JOIN cart c ON ci.cart_id = c.cart_id " +
                     "JOIN products p ON ci.product_id = p.product_id " +
                     "WHERE c.user_id = ?";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setCartItemId(rs.getInt("cart_item_id"));
                    item.setCartId(rs.getInt("cart_id"));
                    item.setProductId(rs.getInt("product_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setProductName(rs.getString("product_name"));
                    item.setProductPrice(rs.getBigDecimal("price"));
                    item.setProductImage(rs.getString("image"));
                    item.setStock(rs.getInt("stock"));
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    public boolean clearCart(int userId) {
        int cartId = getOrCreateCartId(userId);
        if (cartId == 0) return false;

        String sql = "DELETE FROM cart_items WHERE cart_id = ?";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
