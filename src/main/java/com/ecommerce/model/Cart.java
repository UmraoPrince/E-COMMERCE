package com.ecommerce.model;

import java.sql.Timestamp;

public class Cart {
    private int cartId;
    private int userId;
    private Timestamp createdAt;

    public Cart() {}

    public int getCartId() { return cartId; }
    public void setCartId(int cartId) { this.cartId = cartId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
