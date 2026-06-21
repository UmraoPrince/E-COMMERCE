package com.ecommerce.dao;

import com.ecommerce.model.Product;
import com.ecommerce.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public List<Product> getAllProducts(int page, int limit, String searchQuery, Integer categoryId) {
        return getAllProducts(page, limit, searchQuery, categoryId, null, null, null, null);
    }

    public List<Product> getAllProducts(int page, int limit, String searchQuery, Integer categoryId, 
                                        Double minPrice, Double maxPrice, List<String> sources, String sortBy) {
        List<Product> products = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT p.*, c.category_name FROM products p LEFT JOIN categories c ON p.category_id = c.category_id WHERE 1=1");
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND p.product_name LIKE ?");
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ?");
        }
        if (minPrice != null) {
            sql.append(" AND p.price >= ?");
        }
        if (maxPrice != null) {
            sql.append(" AND p.price <= ?");
        }
        if (sources != null && !sources.isEmpty()) {
            sql.append(" AND p.source IN (");
            for (int i = 0; i < sources.size(); i++) {
                sql.append("?");
                if (i < sources.size() - 1) sql.append(",");
            }
            sql.append(")");
        }
        
        if (sortBy != null) {
            if ("price-low".equals(sortBy)) {
                sql.append(" ORDER BY p.price ASC");
            } else if ("price-high".equals(sortBy)) {
                sql.append(" ORDER BY p.price DESC");
            } else if ("rating".equals(sortBy)) {
                sql.append(" ORDER BY p.rating DESC");
            } else {
                sql.append(" ORDER BY p.created_at DESC");
            }
        } else {
            sql.append(" ORDER BY p.created_at DESC");
        }
        
        sql.append(" LIMIT ? OFFSET ?");
        
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + searchQuery.trim() + "%");
            }
            if (categoryId != null && categoryId > 0) {
                ps.setInt(paramIndex++, categoryId);
            }
            if (minPrice != null) {
                ps.setDouble(paramIndex++, minPrice);
            }
            if (maxPrice != null) {
                ps.setDouble(paramIndex++, maxPrice);
            }
            if (sources != null && !sources.isEmpty()) {
                for (String src : sources) {
                    ps.setString(paramIndex++, src);
                }
            }
            
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex, (page - 1) * limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapResultSetToProduct(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    public int getTotalProductsCount(String searchQuery, Integer categoryId) {
        return getTotalProductsCount(searchQuery, categoryId, null, null, null);
    }

    public int getTotalProductsCount(String searchQuery, Integer categoryId, Double minPrice, Double maxPrice, List<String> sources) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products p WHERE 1=1");
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND p.product_name LIKE ?");
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ?");
        }
        if (minPrice != null) {
            sql.append(" AND p.price >= ?");
        }
        if (maxPrice != null) {
            sql.append(" AND p.price <= ?");
        }
        if (sources != null && !sources.isEmpty()) {
            sql.append(" AND p.source IN (");
            for (int i = 0; i < sources.size(); i++) {
                sql.append("?");
                if (i < sources.size() - 1) sql.append(",");
            }
            sql.append(")");
        }

        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;

            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + searchQuery.trim() + "%");
            }
            if (categoryId != null && categoryId > 0) {
                ps.setInt(paramIndex++, categoryId);
            }
            if (minPrice != null) {
                ps.setDouble(paramIndex++, minPrice);
            }
            if (maxPrice != null) {
                ps.setDouble(paramIndex++, maxPrice);
            }
            if (sources != null && !sources.isEmpty()) {
                for (String src : sources) {
                    ps.setString(paramIndex++, src);
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Product getProductById(int id) {
        String sql = "SELECT p.*, c.category_name FROM products p LEFT JOIN categories c ON p.category_id = c.category_id WHERE p.product_id = ?";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProduct(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addProduct(Product product) {
        String sql = "INSERT INTO products (category_id, product_name, description, price, stock, image, source, rating) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (product.getCategoryId() > 0) {
                ps.setInt(1, product.getCategoryId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, product.getProductName());
            ps.setString(3, product.getDescription());
            ps.setBigDecimal(4, product.getPrice());
            ps.setInt(5, product.getStock());
            ps.setString(6, product.getImage());
            ps.setString(7, (product.getSource() != null) ? product.getSource() : "Local");
            ps.setDouble(8, (product.getRating() > 0) ? product.getRating() : 4.0);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateProduct(Product product) {
        boolean updateImage = product.getImage() != null && !product.getImage().isEmpty();
        String sql;
        if (updateImage) {
            sql = "UPDATE products SET category_id = ?, product_name = ?, description = ?, price = ?, stock = ?, image = ?, source = ?, rating = ? WHERE product_id = ?";
        } else {
            sql = "UPDATE products SET category_id = ?, product_name = ?, description = ?, price = ?, stock = ?, source = ?, rating = ? WHERE product_id = ?";
        }

        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (product.getCategoryId() > 0) {
                ps.setInt(1, product.getCategoryId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, product.getProductName());
            ps.setString(3, product.getDescription());
            ps.setBigDecimal(4, product.getPrice());
            ps.setInt(5, product.getStock());
            
            int paramIdx = 6;
            if (updateImage) {
                ps.setString(paramIdx++, product.getImage());
            }
            ps.setString(paramIdx++, (product.getSource() != null) ? product.getSource() : "Local");
            ps.setDouble(paramIdx++, (product.getRating() > 0) ? product.getRating() : 4.0);
            ps.setInt(paramIdx, product.getProductId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteProduct(int productId) {
        String sql = "DELETE FROM products WHERE product_id = ?";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Product> getLowStockProducts(int threshold) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, c.category_name FROM products p LEFT JOIN categories c ON p.category_id = c.category_id WHERE p.stock <= ? ORDER BY p.stock ASC";
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapResultSetToProduct(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    public int getTotalProductsCountAll() {
        String sql = "SELECT COUNT(*) FROM products";
        try (Connection conn = DBUtil.getConnection(); 
             Statement stmt = conn.createStatement(); 
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setCategoryName(rs.getString("category_name"));
        p.setProductName(rs.getString("product_name"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getBigDecimal("price"));
        p.setStock(rs.getInt("stock"));
        p.setImage(rs.getString("image"));
        p.setSource(rs.getString("source"));
        p.setRating(rs.getDouble("rating"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        return p;
    }
}
