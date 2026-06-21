package com.ecommerce.servlet;

import com.ecommerce.dao.ProductDAO;
import com.ecommerce.dao.CategoryDAO;
import com.ecommerce.model.Product;
import com.ecommerce.model.Category;
import com.ecommerce.model.User;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@WebServlet("/admin/products")
public class ProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ProductDAO productDAO = new ProductDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String sessionCsrf = (session != null) ? (String) session.getAttribute("csrfToken") : null;

        if (!ServletFileUpload.isMultipartContent(request)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Form must be multipart/form-data");
            return;
        }

        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        
        // 5MB limit for uploads
        upload.setSizeMax(5 * 1024 * 1024);

        // Upload path: saving to 'uploads' directory under context path
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }

        try {
            List<FileItem> formItems = upload.parseRequest(request);
            Product product = new Product();
            String submittedCsrf = null;
            boolean hasUploadedImage = false;
            String extension = "";
            FileItem imageItem = null;

            // 1. Process fields and check CSRF token first
            for (FileItem item : formItems) {
                if (item.isFormField()) {
                    String fieldName = item.getFieldName();
                    String fieldValue = item.getString("UTF-8");
                    
                    if ("csrfToken".equals(fieldName)) {
                        submittedCsrf = fieldValue;
                    } else {
                        switch (fieldName) {
                            case "name": product.setProductName(fieldValue); break;
                            case "category": product.setCategoryId(Integer.parseInt(fieldValue)); break;
                            case "description": product.setDescription(fieldValue); break;
                            case "price": product.setPrice(new BigDecimal(fieldValue)); break;
                            case "stock": product.setStock(Integer.parseInt(fieldValue)); break;
                            case "source": product.setSource(fieldValue); break;
                            case "rating": 
                                if (fieldValue != null && !fieldValue.trim().isEmpty()) {
                                    product.setRating(Double.parseDouble(fieldValue.trim()));
                                }
                                break;
                            case "id": 
                                if (fieldValue != null && !fieldValue.trim().isEmpty()) {
                                    product.setProductId(Integer.parseInt(fieldValue.trim()));
                                }
                                break;
                        }
                    }
                } else {
                    // This is the file field
                    if (item.getName() != null && !item.getName().trim().isEmpty()) {
                        hasUploadedImage = true;
                        imageItem = item;
                        String originalName = new File(item.getName()).getName();
                        int dotIndex = originalName.lastIndexOf(".");
                        if (dotIndex >= 0) {
                            extension = originalName.substring(dotIndex).toLowerCase();
                        }
                    }
                }
            }

            // 2. Validate CSRF token
            if (sessionCsrf == null || submittedCsrf == null || !sessionCsrf.equals(submittedCsrf)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid or missing CSRF token. Action aborted.");
                return;
            }

            // 3. Process image upload if present, applying secure validations
            if (hasUploadedImage && imageItem != null) {
                // Verify file extensions to prevent executing shell files (e.g. jsp)
                if (!extension.equals(".jpg") && !extension.equals(".jpeg") && 
                    !extension.equals(".png") && !extension.equals(".gif") && !extension.equals(".webp")) {
                    request.setAttribute("error", "Invalid image format. Only JPG, PNG, GIF, and WEBP are allowed.");
                    // Fetch data to re-display products page with error
                    request.setAttribute("products", productDAO.getAllProducts(1, 1000, null, null));
                    request.setAttribute("categories", categoryDAO.getAllCategories());
                    request.getRequestDispatcher("/admin/products.jsp").forward(request, response);
                    return;
                }

                // Randomize file name using UUID to prevent Directory Traversal or overwriting
                String uniqueName = UUID.randomUUID().toString() + extension;
                String filePath = uploadPath + File.separator + uniqueName;
                File storeFile = new File(filePath);
                imageItem.write(storeFile);
                product.setImage("uploads/" + uniqueName);
            }

            // 4. Save to Database
            User adminUser = (User) session.getAttribute("user");
            String adminEmail = (adminUser != null) ? adminUser.getEmail() : "admin@shop.com";
            com.ecommerce.dao.AuditLogDAO auditLogDAO = new com.ecommerce.dao.AuditLogDAO();
            
            if (product.getProductId() > 0) {
                productDAO.updateProduct(product);
                auditLogDAO.logAction("PRODUCT_UPDATE: " + product.getProductName() + " (ID: " + product.getProductId() + ")", adminEmail);
            } else {
                productDAO.addProduct(product);
                auditLogDAO.logAction("PRODUCT_ADD: " + product.getProductName(), adminEmail);
            }
            response.sendRedirect(request.getContextPath() + "/admin/products");

        } catch (Exception ex) {
            ex.printStackTrace();
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Handle Delete via GET
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            HttpSession session = request.getSession(false);
            String sessionCsrf = (session != null) ? (String) session.getAttribute("csrfToken") : null;
            String requestCsrf = request.getParameter("csrfToken");

            // Validate CSRF token to prevent CSRF on delete links
            if (sessionCsrf == null || requestCsrf == null || !sessionCsrf.equals(requestCsrf)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid or missing CSRF token. Delete aborted.");
                return;
            }

            int productId = Integer.parseInt(request.getParameter("id"));
            productDAO.deleteProduct(productId);
            User adminUser = (User) session.getAttribute("user");
            String adminEmail = (adminUser != null) ? adminUser.getEmail() : "admin@shop.com";
            com.ecommerce.dao.AuditLogDAO auditLogDAO = new com.ecommerce.dao.AuditLogDAO();
            auditLogDAO.logAction("PRODUCT_DELETE: ID " + productId, adminEmail);
            response.sendRedirect(request.getContextPath() + "/admin/products");
        } else {
            // Normal MVC page rendering: query list of products and categories, then forward to view
            List<Product> products = productDAO.getAllProducts(1, 1000, null, null);
            List<Category> categories = categoryDAO.getAllCategories();
            
            request.setAttribute("products", products);
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/admin/products.jsp").forward(request, response);
        }
    }
}
