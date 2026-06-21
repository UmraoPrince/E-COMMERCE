package com.ecommerce.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Product {
    private int productId;
    private int categoryId;
    private String categoryName;
    private String productName;
    private String description;
    private BigDecimal price;
    private int stock;
    private String image;
    private String source;
    private double rating;
    private Timestamp createdAt;

    public Product() {}

    public Product(int productId, int categoryId, String productName, String description, BigDecimal price, int stock, String image, String source, double rating, Timestamp createdAt) {
        this.productId = productId;
        this.categoryId = categoryId;
        this.productName = productName;
        this.description = description;
        this.price = price;
        this.stock = stock;
        this.image = image;
        this.source = source;
        this.rating = rating;
        this.createdAt = createdAt;
    }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
