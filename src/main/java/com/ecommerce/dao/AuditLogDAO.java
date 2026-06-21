package com.ecommerce.dao;

import com.ecommerce.model.AuditLog;
import com.ecommerce.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AuditLogDAO {

    public boolean logAction(String action, String userEmail) {
        String sql = "INSERT INTO audit_logs (action, user_email) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, action);
            ps.setString(2, (userEmail != null && !userEmail.isEmpty()) ? userEmail : "Guest");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<AuditLog> getAllLogs() {
        List<AuditLog> logs = new ArrayList<>();
        String sql = "SELECT * FROM audit_logs ORDER BY timestamp DESC";
        try (Connection conn = DBUtil.getConnection(); 
             Statement stmt = conn.createStatement(); 
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                AuditLog log = new AuditLog();
                log.setLogId(rs.getInt("log_id"));
                log.setAction(rs.getString("action"));
                log.setUserEmail(rs.getString("user_email"));
                log.setTimestamp(rs.getTimestamp("timestamp"));
                logs.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return logs;
    }
}
