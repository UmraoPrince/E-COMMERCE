package com.ecommerce.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public class DBUtil {

    private static HikariDataSource dataSource;
    private static boolean isSQLiteMode = false;

    static {
        Properties prop = new Properties();
        boolean loaded = false;
        
        try (InputStream input = DBUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input != null) {
                prop.load(input);
                loaded = true;
            }
        } catch (IOException e) {
            System.err.println("Warning: Could not read db.properties file: " + e.getMessage());
        }

        // 1. Try to connect to MySQL using pooling
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            HikariConfig config = new HikariConfig();
            
            String envDriver = System.getenv("DB_DRIVER");
            String envUrl = System.getenv("DB_URL");
            String envUser = System.getenv("DB_USERNAME");
            String envPass = System.getenv("DB_PASSWORD");

            if (envUrl != null && !envUrl.trim().isEmpty()) {
                config.setDriverClassName(envDriver != null ? envDriver : "com.mysql.cj.jdbc.Driver");
                config.setJdbcUrl(envUrl);
                config.setUsername(envUser != null ? envUser : "");
                config.setPassword(envPass != null ? envPass : "");
                config.setMinimumIdle(2);
                config.setMaximumPoolSize(5);
            } else if (loaded) {
                config.setDriverClassName(prop.getProperty("db.driver"));
                config.setJdbcUrl(prop.getProperty("db.url"));
                config.setUsername(prop.getProperty("db.username"));
                config.setPassword(prop.getProperty("db.password"));
                config.setMinimumIdle(Integer.parseInt(prop.getProperty("db.pool.minIdle", "2")));
                config.setMaximumPoolSize(Integer.parseInt(prop.getProperty("db.pool.maxTotal", "5")));
            } else {
                config.setDriverClassName("com.mysql.cj.jdbc.Driver");
                config.setJdbcUrl("jdbc:mysql://localhost:3306/ecommerce_db");
                config.setUsername("root");
                config.setPassword("password");
                config.setMinimumIdle(2);
                config.setMaximumPoolSize(5);
            }
            
            config.setConnectionTimeout(3000); // Fail fast (3 seconds timeout)
            config.setInitializationFailTimeout(1); // Fail fast on initialization
            
            dataSource = new HikariDataSource(config);
            
            // Test connection
            try (Connection test = dataSource.getConnection()) {
                System.out.println(">>> SUCCESSFULLY Connected to MySQL Database Server! Connection Pool Active.");
            }
            
        } catch (Exception e) {
            System.err.println(">>> MySQL Connection FAILED (" + e.getMessage() + ").");
            System.err.println(">>> FALLING BACK TO SERVERLESS PORTABLE SQLITE MODE...");
            isSQLiteMode = true;
            
            try {
                // Shut down previous pool if open
                if (dataSource != null) {
                    dataSource.close();
                }
                
                // Initialize SQLite
                Class.forName("org.sqlite.JDBC");
                HikariConfig config = new HikariConfig();
                config.setDriverClassName("org.sqlite.JDBC");
                config.setJdbcUrl("jdbc:sqlite:ecommerce.db");
                
                // SQLite allows multiple readers but only 1 writer at a time.
                // Setting max pool size to 1 prevents concurrent "database is locked" errors.
                config.setMaximumPoolSize(1);
                config.setConnectionTimeout(30000); // 30s
                
                dataSource = new HikariDataSource(config);
                
                // Bootstrapper for SQLite tables & seed records
                try (Connection conn = dataSource.getConnection()) {
                    bootstrapSQLiteDatabase(conn);
                    System.out.println(">>> Portable SQLite Database Initialized & Synced successfully!");
                }
                
            } catch (Exception ex) {
                ex.printStackTrace();
                throw new ExceptionInInitializerError("Critical Error initializing fallback SQLite database: " + ex.getMessage());
            }
        }
    }

    /**
     * Get pooled connection (works for both MySQL and SQLite mode).
     */
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    public static boolean isSQLite() {
        return isSQLiteMode;
    }

    /**
     * Close the HikariCP connection pool on shutdown.
     */
    public static void closeDataSource() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }

    /**
     * Bootstraps schema and seeds admin/categories/products for SQLite databases.
     */
    private static void bootstrapSQLiteDatabase(Connection conn) throws SQLException {
        // Check if tables exist
        boolean tablesExist = false;
        String checkSql = "SELECT name FROM sqlite_master WHERE type='table' AND name='users'";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(checkSql)) {
            if (rs.next()) {
                tablesExist = true;
            }
        }

        if (tablesExist) {
            return; // Already initialized
        }

        System.out.println(">>> Bootstrapping new SQLite database tables...");
        try (Statement stmt = conn.createStatement()) {
            // Enforce foreign keys
            stmt.execute("PRAGMA foreign_keys = ON;");

            // 1. Users table
            stmt.execute("CREATE TABLE IF NOT EXISTS users (" +
                         "user_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                         "name TEXT NOT NULL," +
                         "email TEXT UNIQUE NOT NULL," +
                         "mobile TEXT," +
                         "password TEXT NOT NULL," +
                         "address TEXT," +
                         "role TEXT DEFAULT 'USER'," +
                         "verified INTEGER DEFAULT 0," +
                         "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                         ");");

            // 2. Categories table
            stmt.execute("CREATE TABLE IF NOT EXISTS categories (" +
                         "category_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                         "category_name TEXT NOT NULL," +
                         "description TEXT" +
                         ");");

            // 3. Products table
            stmt.execute("CREATE TABLE IF NOT EXISTS products (" +
                         "product_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                         "category_id INTEGER," +
                         "product_name TEXT NOT NULL," +
                         "description TEXT," +
                         "price DECIMAL(10, 2) NOT NULL," +
                         "stock INTEGER DEFAULT 0 CHECK (stock >= 0)," +
                         "image TEXT," +
                         "source TEXT DEFAULT 'Local'," +
                         "rating DECIMAL(3, 2) DEFAULT 4.0," +
                         "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                         "FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL" +
                         ");");

            // 4. Cart table
            stmt.execute("CREATE TABLE IF NOT EXISTS cart (" +
                         "cart_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                         "user_id INTEGER UNIQUE," +
                         "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                         "FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE" +
                         ");");

            // 5. Cart Items table
            stmt.execute("CREATE TABLE IF NOT EXISTS cart_items (" +
                         "cart_item_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                         "cart_id INTEGER," +
                         "product_id INTEGER," +
                         "quantity INTEGER DEFAULT 1 CHECK (quantity > 0)," +
                         "FOREIGN KEY (cart_id) REFERENCES cart(cart_id) ON DELETE CASCADE," +
                         "FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE," +
                         "UNIQUE(cart_id, product_id)" +
                         ");");

            // 6. Orders table
            stmt.execute("CREATE TABLE IF NOT EXISTS orders (" +
                         "order_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                         "user_id INTEGER," +
                         "total_amount DECIMAL(10, 2) NOT NULL," +
                         "order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                         "status TEXT DEFAULT 'PENDING'," +
                         "shipping_address TEXT NOT NULL," +
                         "FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL" +
                         ");");

            // 7. Order Items table
            stmt.execute("CREATE TABLE IF NOT EXISTS order_items (" +
                         "order_item_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                         "order_id INTEGER," +
                         "product_id INTEGER," +
                         "quantity INTEGER NOT NULL CHECK (quantity > 0)," +
                         "price DECIMAL(10, 2) NOT NULL," +
                         "FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE," +
                         "FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE SET NULL" +
                         ");");

            // 8. Payments table
            stmt.execute("CREATE TABLE IF NOT EXISTS payments (" +
                         "payment_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                         "order_id INTEGER," +
                         "payment_method TEXT DEFAULT 'COD'," +
                         "transaction_id TEXT UNIQUE," +
                         "payment_status TEXT DEFAULT 'PENDING'," +
                         "payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                         "amount DECIMAL(10, 2)," +
                         "FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE" +
                         ");");

            // 9. Wishlist table
            stmt.execute("CREATE TABLE IF NOT EXISTS wishlist (" +
                         "wishlist_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                         "user_id INTEGER," +
                         "product_id INTEGER," +
                         "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                         "FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE," +
                         "FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE," +
                         "UNIQUE(user_id, product_id)" +
                         ");");

            // 10. Reviews table
            stmt.execute("CREATE TABLE IF NOT EXISTS reviews (" +
                         "review_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                         "user_id INTEGER," +
                         "product_id INTEGER," +
                         "rating INTEGER CHECK (rating BETWEEN 1 AND 5)," +
                         "review_text TEXT," +
                         "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                         "FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE," +
                         "FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE" +
                         ");");

            // 11. Audit Logs table
            stmt.execute("CREATE TABLE IF NOT EXISTS audit_logs (" +
                         "log_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                         "action TEXT NOT NULL," +
                         "user_email TEXT NOT NULL," +
                         "timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                         ");");

            // Seed Admin User (password: admin123 - legacy SHA-256 hash fallback)
            stmt.execute("INSERT INTO users (name, email, mobile, password, address, role, verified) " +
                         "VALUES ('Admin', 'admin@shop.com', '9999999999', '240be518fabd2724ddb6f04eeb9d5b04c5db5d8a8a27e7db2b90f1574db0a51d', 'Admin Address', 'ADMIN', 1);");

            // Seed Categories
            stmt.execute("INSERT INTO categories (category_name, description) VALUES ('Electronics', 'Gadgets and Devices');");
            stmt.execute("INSERT INTO categories (category_name, description) VALUES ('Fashion', 'Clothing and Accessories');");
            stmt.execute("INSERT INTO categories (category_name, description) VALUES ('Home Appliances', 'Kitchen and Home tools');");

            // Seed Products
            stmt.execute("INSERT INTO products (category_id, product_name, description, price, stock, image, source, rating) " +
                         "VALUES (1, 'Smartphone X', 'Latest smartphone with high res camera', 57999.00, 50, 'uploads/phone.jpg', 'Amazon', 4.5);");
            stmt.execute("INSERT INTO products (category_id, product_name, description, price, stock, image, source, rating) " +
                         "VALUES (2, 'Denim Jacket', 'Stylish blue denim jacket', 2499.00, 100, 'uploads/jacket.jpg', 'AliExpress', 4.0);");
            stmt.execute("INSERT INTO products (category_id, product_name, description, price, stock, image, source, rating) " +
                         "VALUES (1, 'Laptop Pro', 'High performance laptop', 82999.00, 20, 'uploads/laptop.jpg', 'BestBuy', 4.8);");
            stmt.execute("INSERT INTO products (category_id, product_name, description, price, stock, image, source, rating) " +
                         "VALUES (1, 'ProWireless Headphones', 'Noise cancelling, 20h battery life.', 9999.00, 50, 'uploads/headphones.jpg', 'Amazon', 4.5);");
            stmt.execute("INSERT INTO products (category_id, product_name, description, price, stock, image, source, rating) " +
                         "VALUES (1, 'Smart Watch Gen 5', 'Heart rate monitor, GPS.', 14999.00, 5, 'uploads/watch.jpg', 'BestBuy', 4.8);");
            stmt.execute("INSERT INTO products (category_id, product_name, description, price, stock, image, source, rating) " +
                         "VALUES (2, 'Cotton Running Tee', 'Breathable fabric for athletes.', 999.00, 100, 'uploads/tee.jpg', 'AliExpress', 4.0);");
            stmt.execute("INSERT INTO products (category_id, product_name, description, price, stock, image, source, rating) " +
                         "VALUES (3, 'Ergonomic Office Chair', 'Lumbar support, mesh back.', 8999.00, 12, 'uploads/chair.jpg', 'Walmart', 4.2);");
            stmt.execute("INSERT INTO products (category_id, product_name, description, price, stock, image, source, rating) " +
                         "VALUES (3, 'Yoga Mat Premium', 'Non-slip, extra thick.', 1299.00, 0, 'uploads/mat.jpg', 'Amazon', 4.9);");
            stmt.execute("INSERT INTO products (category_id, product_name, description, price, stock, image, source, rating) " +
                         "VALUES (1, '4K Monitor 27\"', 'IPS panel, HDR ready.', 24999.00, 20, 'uploads/monitor.jpg', 'Newegg', 4.6);");
        }
    }
}
