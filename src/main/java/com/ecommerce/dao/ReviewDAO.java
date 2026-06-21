package com.ecommerce.dao;

import com.ecommerce.model.Review;
import com.ecommerce.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    public boolean addReview(Review review) {
        String sql = "INSERT INTO reviews (user_id, product_id, rating, review_text) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, review.getUserId());
            ps.setInt(2, review.getProductId());
            ps.setInt(3, review.getRating());
            ps.setString(4, review.getReviewText());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Review> getReviewsForProduct(int productId) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.review_id, r.user_id, r.product_id, r.rating, r.review_text, r.created_at, " +
                     "u.name as user_name " +
                     "FROM reviews r " +
                     "JOIN users u ON r.user_id = u.user_id " +
                     "WHERE r.product_id = ? " +
                     "ORDER BY r.created_at DESC";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getInt("review_id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setProductId(rs.getInt("product_id"));
                    r.setRating(rs.getInt("rating"));
                    r.setReviewText(rs.getString("review_text"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    r.setUserName(rs.getString("user_name"));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public double getAverageRatingForProduct(int productId) {
        String sql = "SELECT AVG(rating) FROM reviews WHERE product_id = ?";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
}
