package com.ecommerce.model;

import java.sql.Timestamp;

public class User {
    private int userId;
    private String name;
    private String email;
    private String mobile;
    private String password;
    private String address;
    private String role;
    private boolean verified;
    private Timestamp createdAt;

    public User() {}

    public User(int userId, String name, String email, String mobile, String password, String address, String role, boolean verified, Timestamp createdAt) {
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.mobile = mobile;
        this.password = password;
        this.address = address;
        this.role = role;
        this.verified = verified;
        this.createdAt = createdAt;
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getMobile() { return mobile; }
    public void setMobile(String mobile) { this.mobile = mobile; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isVerified() { return verified; }
    public void setVerified(boolean verified) { this.verified = verified; }
}
