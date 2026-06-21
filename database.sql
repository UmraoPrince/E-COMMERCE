-- Create Database
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    mobile VARCHAR(15),
    password VARCHAR(255) NOT NULL,
    address TEXT,
    role ENUM('USER', 'ADMIN') DEFAULT 'USER',
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Categories Table
CREATE TABLE IF NOT EXISTS categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description TEXT
);

-- 3. Products Table
CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0 CHECK (stock >= 0),
    image VARCHAR(255),
    source VARCHAR(50) DEFAULT 'Local',
    rating DECIMAL(3, 2) DEFAULT 4.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Indexes for performance on products table
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_name ON products(product_name);

-- 4. Cart Table
CREATE TABLE IF NOT EXISTS cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 5. Cart Items Table
CREATE TABLE IF NOT EXISTS cart_items (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT,
    product_id INT,
    quantity INT DEFAULT 1 CHECK (quantity > 0),
    FOREIGN KEY (cart_id) REFERENCES cart(cart_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_cart_product (cart_id, product_id)
);

CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);

-- 6. Orders Table
CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    total_amount DECIMAL(10, 2) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDING', 'CONFIRMED', 'SHIPPED', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED') DEFAULT 'PENDING',
    shipping_address TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE INDEX idx_orders_user ON orders(user_id);

-- 7. Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE SET NULL
);

CREATE INDEX idx_order_items_order ON order_items(order_id);

-- 8. Payments Table
CREATE TABLE IF NOT EXISTS payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(50) DEFAULT 'COD',
    transaction_id VARCHAR(100) UNIQUE,
    payment_status VARCHAR(50) DEFAULT 'PENDING',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

-- 9. Wishlist Table
CREATE TABLE IF NOT EXISTS wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_wishlist (user_id, product_id)
);

-- 10. Reviews Table
CREATE TABLE IF NOT EXISTS reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- 11. Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    message VARCHAR(255) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 12. Audit Logs Table
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(255) NOT NULL,
    user_email VARCHAR(100) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert Default Admin (Password: admin123 - hashed with simple SHA-256 for demo fallback)
INSERT INTO users (name, email, mobile, password, address, role, verified) 
VALUES ('Admin', 'admin@shop.com', '9999999999', '240be518fabd2724ddb6f04eeb9d5b04c5db5d8a8a27e7db2b90f1574db0a51d', 'Admin Address', 'ADMIN', true);

-- Insert Sample Categories
INSERT INTO categories (category_name, description) VALUES 
('Electronics', 'Gadgets and Devices'),
('Fashion', 'Clothing and Accessories'),
('Home Appliances', 'Kitchen and Home tools');

-- Insert Sample Products
INSERT INTO products (category_id, product_name, description, price, stock, image, source, rating) VALUES 
(1, 'Smartphone X', 'Latest smartphone with high res camera', 699.99, 50, 'uploads/phone.jpg', 'Amazon', 4.5),
(2, 'Denim Jacket', 'Stylish blue denim jacket', 49.99, 100, 'uploads/jacket.jpg', 'AliExpress', 4.0),
(1, 'Laptop Pro', 'High performance laptop', 999.99, 20, 'uploads/laptop.jpg', 'BestBuy', 4.8),
(1, 'ProWireless Headphones', 'Noise cancelling, 20h battery life.', 199.00, 50, 'uploads/headphones.jpg', 'Amazon', 4.5),
(1, 'Smart Watch Gen 5', 'Heart rate monitor, GPS.', 299.00, 5, 'uploads/watch.jpg', 'BestBuy', 4.8),
(2, 'Cotton Running Tee', 'Breathable fabric for athletes.', 25.00, 100, 'uploads/tee.jpg', 'AliExpress', 4.0),
(3, 'Ergonomic Office Chair', 'Lumbar support, mesh back.', 150.00, 12, 'uploads/chair.jpg', 'Walmart', 4.2),
(3, 'Yoga Mat Premium', 'Non-slip, extra thick.', 45.00, 0, 'uploads/mat.jpg', 'Amazon', 4.9),
(1, '4K Monitor 27"', 'IPS panel, HDR ready.', 350.00, 20, 'uploads/monitor.jpg', 'Newegg', 4.6);
