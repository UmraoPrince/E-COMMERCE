<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.util.DBUtil" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    HttpSession dashSession = request.getSession(false);
    User currentUser = (dashSession != null) ? (User) dashSession.getAttribute("user") : null;
    if (currentUser == null) {
        response.sendRedirect("login.jsp?error=Authentication+required");
        return;
    }

    // Handle Wishlist additions/deletions directly in JSP Controller block
    String action = request.getParameter("action");
    if (action != null) {
        String token = request.getParameter("csrfToken");
        String sessionCsrf = (String) session.getAttribute("csrfToken");
        
        if (sessionCsrf != null && sessionCsrf.equals(token)) {
            if ("delete".equals(action)) {
                String idStr = request.getParameter("id");
                if (idStr != null) {
                    int wishlistId = Integer.parseInt(idStr);
                    try (Connection conn = DBUtil.getConnection(); 
                         PreparedStatement ps = conn.prepareStatement("DELETE FROM wishlist WHERE wishlist_id = ? AND user_id = ?")) {
                        ps.setInt(1, wishlistId);
                        ps.setInt(2, currentUser.getUserId());
                        ps.executeUpdate();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            } else if ("add".equals(action)) {
                String prodIdStr = request.getParameter("productId");
                if (prodIdStr != null) {
                    int productId = Integer.parseInt(prodIdStr);
                    try (Connection conn = DBUtil.getConnection()) {
                        // Check if already in wishlist to ensure portable behavior on MySQL/SQLite
                        boolean exists = false;
                        try (PreparedStatement checkPs = conn.prepareStatement("SELECT 1 FROM wishlist WHERE user_id = ? AND product_id = ?")) {
                            checkPs.setInt(1, currentUser.getUserId());
                            checkPs.setInt(2, productId);
                            try (ResultSet rs = checkPs.executeQuery()) {
                                if (rs.next()) {
                                    exists = true;
                                }
                            }
                        }
                        if (!exists) {
                            try (PreparedStatement ps = conn.prepareStatement("INSERT INTO wishlist (user_id, product_id) VALUES (?, ?)")) {
                                ps.setInt(1, currentUser.getUserId());
                                ps.setInt(2, productId);
                                ps.executeUpdate();
                            }
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
            response.sendRedirect("dashboard.jsp");
            return;
        } else {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF Token");
            return;
        }
    }

    // Load Wishlist items from DB
    List<Map<String, Object>> wishlistItems = new ArrayList<>();
    String wishSql = "SELECT w.wishlist_id, w.product_id, p.product_name, p.price, p.image, p.stock " +
                     "FROM wishlist w " +
                     "JOIN products p ON w.product_id = p.product_id " +
                     "WHERE w.user_id = ?";
                     
    try (Connection conn = DBUtil.getConnection(); 
         PreparedStatement ps = conn.prepareStatement(wishSql)) {
        ps.setInt(1, currentUser.getUserId());
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("wishlistId", rs.getInt("wishlist_id"));
                map.put("productId", rs.getInt("product_id"));
                map.put("productName", rs.getString("product_name"));
                map.put("price", rs.getBigDecimal("price"));
                map.put("image", rs.getString("image"));
                map.put("stock", rs.getInt("stock"));
                wishlistItems.add(map);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    request.setAttribute("wishlist", wishlistItems);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy - Dashboard & Profile</title>
</head>
<body>
    <%@ include file="components/navbar.jsp" %>

    <div class="container mt-5">
        <div class="row">
            <!-- Left Side: Profile Form -->
            <div class="col-lg-5 mb-4">
                <div class="glass-panel">
                    <h5 class="text-white mb-4"><i class="bi bi-person-gear text-indigo"></i> Profile Settings</h5>
                    
                    <!-- Success banner -->
                    <c:if test="${param.profileSuccess == 1}">
                        <div class="custom-alert text-center">
                            <i class="bi bi-check-circle-fill"></i> Profile updated successfully!
                        </div>
                    </c:if>

                    <c:if test="${not empty error}">
                        <div class="custom-alert-error text-center">
                            <i class="bi bi-exclamation-triangle-fill"></i> <c:out value="${error}" />
                        </div>
                    </c:if>

                    <form action="auth" method="POST">
                        <input type="hidden" name="action" value="updateProfile">
                        <!-- CSRF Token -->
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

                        <div class="mb-3">
                            <label class="form-label text-muted">Email Address (Locked)</label>
                            <input type="email" class="form-control bg-dark text-muted" value="<c:out value='${sessionScope.user.email}' />" readonly disabled style="opacity: 0.6;">
                        </div>

                        <div class="mb-3">
                            <label class="form-label text-muted">Full Name *</label>
                            <input type="text" name="name" class="form-control" value="<c:out value='${sessionScope.user.name}' />" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label text-muted">Mobile Number</label>
                            <input type="tel" name="mobile" class="form-control" value="<c:out value='${sessionScope.user.mobile}' />">
                        </div>

                        <div class="mb-4">
                            <label class="form-label text-muted">Shipping Address</label>
                            <textarea name="address" class="form-control" rows="3"><c:out value="${sessionScope.user.address}" /></textarea>
                        </div>

                        <button type="submit" class="btn btn-primary w-100">Update Profile</button>
                    </form>
                </div>
            </div>

            <!-- Right Side: Wishlist Details -->
            <div class="col-lg-7">
                <div class="glass-panel">
                    <h5 class="text-white mb-4"><i class="bi bi-heart-fill text-indigo"></i> My Saved Items (Wishlist)</h5>
                    
                    <c:choose>
                        <c:when test="${empty wishlist}">
                            <div class="text-center py-5 text-muted">
                                <i class="bi bi-heartbreak fs-2 mb-2 d-block"></i>
                                <p>You haven't saved any items yet.</p>
                                <a href="index.jsp" class="btn btn-outline-light btn-sm mt-2">Discover Products</a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="table text-white mb-0" style="vertical-align: middle;">
                                    <thead>
                                        <tr>
                                            <th>Product</th>
                                            <th>Price</th>
                                            <th>Status</th>
                                            <th class="text-center">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${wishlist}">
                                            <tr>
                                                <td>
                                                    <div class="d-flex align-items-center">
                                                        <c:choose>
                                                            <c:when test="${not empty item.image}">
                                                                <img src="${pageContext.request.contextPath}/${item.image}" style="width: 45px; height: 45px; object-fit: cover; border-radius: 6px;" class="me-2" alt="Product">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="d-flex align-items-center justify-content-center text-muted bg-dark me-2" style="width: 45px; height: 45px; border-radius: 6px;">
                                                                    <i class="bi bi-image"></i>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <span class="text-truncate" style="max-width: 140px;">
                                                            <a href="product-details.jsp?id=${item.productId}" class="text-white text-decoration-none"><c:out value="${item.productName}" /></a>
                                                        </span>
                                                    </div>
                                                </td>
                                                <td class="text-success">₹<c:out value="${item.price}" /></td>
                                                <td>
                                                    <span class="badge ${item.stock > 0 ? 'bg-success' : 'bg-danger'}">
                                                        ${item.stock > 0 ? 'In Stock' : 'Out of Stock'}
                                                    </span>
                                                </td>
                                                <td class="text-center">
                                                    <div class="d-flex justify-content-center gap-2">
                                                        <!-- Add to Cart -->
                                                        <button class="btn btn-sm btn-primary" onclick="addToCart(${item.productId})" ${item.stock <= 0 ? 'disabled' : ''}>
                                                            <i class="bi bi-cart-plus"></i>
                                                        </button>
                                                        
                                                        <!-- Remove from Wishlist -->
                                                        <a href="dashboard.jsp?action=delete&id=${item.wishlistId}&csrfToken=${sessionScope.csrfToken}" class="btn btn-sm btn-danger">
                                                            <i class="bi bi-trash"></i>
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <!-- Core Scripting Dependencies -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
