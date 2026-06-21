<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // Safely redirect direct JSP accesses to the servlet controller so databases are queried
    if (request.getAttribute("products") == null) {
        response.sendRedirect("products");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy Admin - Products</title>
</head>
<body>
    <%@ include file="../components/admin_navbar.jsp" %>

    <div class="container-fluid py-4 px-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="text-white mb-0"><i class="bi bi-box-seam text-warning"></i> Product Inventory Manager</h3>
            <a href="editProduct.jsp" class="btn btn-warning fw-bold">
                <i class="bi bi-plus-lg"></i> Add New Product
            </a>
        </div>

        <c:if test="${not empty error}">
            <div class="custom-alert-error text-center mb-4">
                <i class="bi bi-exclamation-triangle-fill"></i> <c:out value="${error}" />
            </div>
        </c:if>

        <div class="glass-panel">
            <div class="table-responsive">
                <table class="table text-white mb-0" style="vertical-align: middle;">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Image</th>
                            <th>Product Name</th>
                            <th>Category</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th class="text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty products}">
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-4">No products found in database. Click "Add New Product" to populate the catalog.</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="p" items="${products}">
                                    <tr>
                                        <td>#${p.productId}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty p.image}">
                                                    <img src="${pageContext.request.contextPath}/${p.image}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 6px;" alt="Product">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="d-flex align-items-center justify-content-center text-muted bg-dark" style="width: 50px; height: 50px; border-radius: 6px;">
                                                        <i class="bi bi-image"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="fw-bold"><c:out value="${p.productName}" /></td>
                                        <td>
                                            <span class="badge bg-secondary text-uppercase"><c:out value="${p.categoryName}" /></span>
                                        </td>
                                        <td class="text-success fw-bold">₹<c:out value="${p.price}" /></td>
                                        <td>
                                            <span class="fw-bold ${p.stock <= 5 ? 'text-danger' : 'text-light'}">${p.stock}</span>
                                        </td>
                                        <td class="text-center">
                                            <div class="d-flex justify-content-center gap-2">
                                                <!-- Edit button -->
                                                <a href="editProduct.jsp?id=${p.productId}" class="btn btn-sm btn-primary">
                                                    <i class="bi bi-pencil-square"></i> Edit
                                                </a>
                                                
                                                <!-- Delete link with query-param CSRF token validation -->
                                                <a href="products?action=delete&id=${p.productId}&csrfToken=${sessionScope.csrfToken}" 
                                                   class="btn btn-sm btn-danger" 
                                                   onclick="return confirm('Are you sure you want to delete this product?');">
                                                    <i class="bi bi-trash"></i> Delete
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Core Scripting Dependencies -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
