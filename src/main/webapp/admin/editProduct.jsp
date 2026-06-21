<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.ecommerce.dao.ProductDAO" %>
<%@ page import="com.ecommerce.dao.CategoryDAO" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.model.Category" %>
<%@ page import="java.util.List" %>
<%
    String idStr = request.getParameter("id");
    Product product = null;
    if (idStr != null && !idStr.trim().isEmpty()) {
        try {
            int prodId = Integer.parseInt(idStr.trim());
            product = new ProductDAO().getProductById(prodId);
        } catch (NumberFormatException e) {
            // ignore bad formatting
        }
    }
    List<Category> categories = new CategoryDAO().getAllCategories();
    request.setAttribute("product", product);
    request.setAttribute("categories", categories);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy Admin - ${empty product ? 'Add Product' : 'Edit Product'}</title>
</head>
<body>
    <%@ include file="../components/admin_navbar.jsp" %>

    <div class="container mt-5">
        <a href="products" class="btn btn-outline-light btn-sm mb-4"><i class="bi bi-arrow-left"></i> Back to Inventory</a>

        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="glass-panel">
                    <h4 class="text-white mb-4">
                        <i class="bi ${empty product ? 'bi-plus-circle' : 'bi-pencil-square'} text-warning"></i>
                        ${empty product ? 'Create New Product' : 'Modify Product Details'}
                    </h4>

                    <form action="products" method="POST" enctype="multipart/form-data">
                        <!-- CSRF Token -->
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        
                        <!-- Product ID (Only for edit) -->
                        <input type="hidden" name="id" value="${product != null ? product.productId : ''}">

                        <div class="row">
                            <!-- Product Name -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted">Product Name *</label>
                                <input type="text" name="name" class="form-control" required placeholder="Enter product name" value="<c:out value='${product.productName}' />">
                            </div>

                            <!-- Category Selection -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted">Category *</label>
                                <select name="category" class="form-select" required>
                                    <option value="" disabled ${empty product ? 'selected' : ''}>Choose category...</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.categoryId}" ${product != null && product.categoryId == cat.categoryId ? 'selected' : ''}>
                                            <c:out value="${cat.categoryName}" />
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>

                        <div class="row">
                            <!-- Unit Price -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted">Price (₹ INR) *</label>
                                <input type="number" step="0.01" min="0.01" name="price" class="form-control" required placeholder="0.00" value="${product != null ? product.price : ''}">
                            </div>

                            <!-- Stock Levels -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted">Stock Quantity *</label>
                                <input type="number" min="0" name="stock" class="form-control" required placeholder="0" value="${product != null ? product.stock : ''}">
                            </div>
                        </div>

                        <div class="row">
                            <!-- Product Source -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted">Partner Source *</label>
                                <select name="source" class="form-select" required>
                                    <option value="Local" ${product != null && product.source == 'Local' ? 'selected' : ''}>Local</option>
                                    <option value="Amazon" ${product != null && product.source == 'Amazon' ? 'selected' : ''}>Amazon</option>
                                    <option value="AliExpress" ${product != null && product.source == 'AliExpress' ? 'selected' : ''}>AliExpress</option>
                                    <option value="Walmart" ${product != null && product.source == 'Walmart' ? 'selected' : ''}>Walmart</option>
                                    <option value="BestBuy" ${product != null && product.source == 'BestBuy' ? 'selected' : ''}>BestBuy</option>
                                    <option value="Newegg" ${product != null && product.source == 'Newegg' ? 'selected' : ''}>Newegg</option>
                                </select>
                            </div>

                            <!-- Initial Rating -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted">Product Rating (1.0 to 5.0) *</label>
                                <input type="number" step="0.1" min="1.0" max="5.0" name="rating" class="form-control" required placeholder="4.0" value="${product != null ? product.rating : '4.0'}">
                            </div>
                        </div>

                        <!-- Image File Upload -->
                        <div class="mb-3">
                            <label class="form-label text-muted">Product Image ${empty product ? '*' : '(Optional)'}</label>
                            <input type="file" name="image" class="form-control" ${empty product ? 'required' : ''}>
                            <div class="form-text text-muted small">Allowed formats: JPG, JPEG, PNG, GIF, WEBP. Maximum size: 5MB.</div>
                            
                            <!-- Display current image if editing -->
                            <c:if test="${product != null && not empty product.image}">
                                <div class="mt-3">
                                    <span class="text-muted d-block small mb-1">Current Image:</span>
                                    <img src="${pageContext.request.contextPath}/${product.image}" style="width: 100px; height: 100px; object-fit: cover; border-radius: 8px; border: 1px solid var(--panel-border);" alt="Preview">
                                </div>
                            </c:if>
                        </div>

                        <!-- Product Description -->
                        <div class="mb-4">
                            <label class="form-label text-muted">Product Description</label>
                            <textarea name="description" class="form-control" rows="4" placeholder="Enter detailed specifications or descriptions..."><c:out value="${product.description}" /></textarea>
                        </div>

                        <div class="d-flex justify-content-end gap-2">
                            <a href="products" class="btn btn-outline-light px-4">Cancel</a>
                            <button type="submit" class="btn btn-primary px-4 fw-bold">
                                <i class="bi bi-save"></i> ${empty product ? 'Add Product' : 'Save Changes'}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Core Scripting Dependencies -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
