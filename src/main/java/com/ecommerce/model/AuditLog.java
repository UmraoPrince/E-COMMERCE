package com.ecommerce.model;

import java.sql.Timestamp;

public class AuditLog {
    private int logId;
    private String action;
    private String userEmail;
    private Timestamp timestamp;

    public AuditLog() {}

    public AuditLog(int logId, String action, String userEmail, Timestamp timestamp) {
        this.logId = logId;
        this.action = action;
        this.userEmail = userEmail;
        this.timestamp = timestamp;
    }

    public int getLogId() { return logId; }
    public void setLogId(int logId) { this.logId = logId; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public Timestamp getTimestamp() { return timestamp; }
    public void setTimestamp(Timestamp timestamp) { this.timestamp = timestamp; }
}
