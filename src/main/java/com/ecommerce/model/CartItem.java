package com.ecommerce.model;

import java.math.BigDecimal;

public class CartItem {
    private int cartItemId;
    private int cartId;
    private int productId;
    private int quantity;

    // Helper fields for easy front-end display
    private String productName;
    private BigDecimal productPrice;
    private String productImage;
    private int stock;

    public CartItem() {}

    public int getCartItemId() { return cartItemId; }
    public void setCartItemId(int cartItemId) { this.cartItemId = cartItemId; }

    public int getCartId() { return cartId; }
    public void setCartId(int cartId) { this.cartId = cartId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public BigDecimal getProductPrice() { return productPrice; }
    public void setProductPrice(BigDecimal productPrice) { this.productPrice = productPrice; }

    public String getProductImage() { return productImage; }
    public void setProductImage(String productImage) { this.productImage = productImage; }

    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }

    // Helper to calculate total price of this cart item row
    public BigDecimal getSubtotal() {
        if (productPrice == null) return BigDecimal.ZERO;
        return productPrice.multiply(new BigDecimal(quantity));
    }
}
