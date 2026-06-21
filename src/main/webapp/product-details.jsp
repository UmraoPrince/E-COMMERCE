<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.ecommerce.dao.ProductDAO" %>
<%@ page import="com.ecommerce.dao.ReviewDAO" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.model.Review" %>
<%@ page import="java.util.List" %>
<%
    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect("index.jsp");
        return;
    }
    try {
        int productId = Integer.parseInt(idStr);
        ProductDAO pDAO = new ProductDAO();
        ReviewDAO rDAO = new ReviewDAO();
        
        Product product = pDAO.getProductById(productId);
        if (product == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        List<Review> reviews = rDAO.getReviewsForProduct(productId);
        double avgRating = rDAO.getAverageRatingForProduct(productId);
        
        request.setAttribute("product", product);
        request.setAttribute("reviews", reviews);
        request.setAttribute("avgRating", avgRating);
    } catch (NumberFormatException e) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy - <c:out value="${product.productName}" /></title>
</head>
<body>
    <%@ include file="components/navbar.jsp" %>

    <div class="container mt-5">
        <!-- Back link -->
        <a href="index.jsp" class="btn btn-outline-light btn-sm mb-4"><i class="bi bi-arrow-left"></i> Back to Catalog</a>

        <!-- Product Details Panel -->
        <div class="glass-panel mb-5">
            <div class="row">
                <!-- Column 1: Image -->
                <div class="col-md-5 mb-4 mb-md-0">
                    <div style="background: rgba(0, 0, 0, 0.2); border-radius: 12px; overflow:hidden;" class="text-center p-3">
                        <c:choose>
                            <c:when test="${not empty product.image}">
                                <img src="${pageContext.request.contextPath}/${product.image}" class="img-fluid" style="max-height: 400px; border-radius: 8px;" alt="<c:out value='${product.productName}' />">
                            </c:when>
                            <c:otherwise>
                                <div class="d-flex align-items-center justify-content-center text-muted" style="height: 300px;">
                                    <i class="bi bi-image fs-1" style="font-size: 5rem !important;"></i>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Column 2: Information -->
                <div class="col-md-7 d-flex flex-column justify-content-between">
                    <div>
                        <div class="d-flex gap-2 align-items-center flex-wrap mb-2">
                            <span class="badge bg-primary text-uppercase px-2 py-1"><c:out value="${product.categoryName}" /></span>
                            <span class="badge bg-dark text-light border border-secondary px-2 py-1">via <c:out value="${product.source}" /></span>
                        </div>
                        <h2 class="text-white mt-2 mb-1"><c:out value="${product.productName}" /></h2>
                        
                        <!-- Rating Summary -->
                        <div class="d-flex align-items-center mb-3">
                            <span class="text-warning me-2">
                                <c:forEach var="i" begin="1" end="5">
                                    <i class="bi ${i <= product.rating ? 'bi-star-fill' : (i - 0.5 <= product.rating ? 'bi-star-half' : 'bi-star')}"></i>
                                </c:forEach>
                            </span>
                            <span class="text-muted small">Catalog Rating: ${product.rating} / 5</span>
                            <span class="text-muted small ms-3">| Customer Reviews: (${avgRating > 0 ? String.format("%.1f", avgRating) : 'No reviews'})</span>
                        </div>

                        <hr style="background-color: var(--panel-border);">

                        <h3 class="text-success mb-3">₹<c:out value="${product.price}" /></h3>

                        <h6 class="text-muted">Description:</h6>
                        <p class="text-light" style="line-height: 1.6;"><c:out value="${product.description}" /></p>
                    </div>

                    <div class="mt-4">
                        <div class="d-flex align-items-center mb-3">
                            <h6 class="text-muted mb-0 me-3">Stock Status:</h6>
                            <c:choose>
                                <c:when test="${product.stock > 0}">
                                    <span class="badge bg-success"><i class="bi bi-check-circle"></i> In Stock (${product.stock} available)</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-danger"><i class="bi bi-x-circle"></i> Out of Stock</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <div class="row g-2 mt-2">
                            <div class="col-8">
                                <button class="btn btn-primary btn-lg w-100 py-3" onclick="addToCart(${product.productId})" ${product.stock <= 0 ? 'disabled' : ''}>
                                    <i class="bi bi-cart-plus-fill"></i> Add Product to Shopping Cart
                                </button>
                            </div>
                            <div class="col-4">
                                <a href="dashboard.jsp?action=add&productId=${product.productId}&csrfToken=${sessionScope.csrfToken}" class="btn btn-outline-danger btn-lg w-100 py-3" title="Save to Wishlist">
                                    <i class="bi bi-heart-fill"></i> Save
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Reviews Panel -->
        <div class="row">
            <!-- Write a Review Form -->
            <div class="col-lg-4 mb-4">
                <div class="glass-panel">
                    <h5 class="text-white mb-3"><i class="bi bi-chat-left-text text-indigo"></i> Write a Review</h5>
                    <c:choose>
                        <c:when test="${not empty sessionScope.user}">
                            <form action="review" method="POST">
                                <input type="hidden" name="productId" value="${product.productId}">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

                                <div class="mb-3">
                                    <label class="form-label text-muted">Your Rating:</label>
                                    <div class="star-rating-input">
                                        <input type="radio" id="star5" name="rating" value="5" required><label for="star5" class="bi bi-star-fill"></label>
                                        <input type="radio" id="star4" name="rating" value="4"><label for="star4" class="bi bi-star-fill"></label>
                                        <input type="radio" id="star3" name="rating" value="3"><label for="star3" class="bi bi-star-fill"></label>
                                        <input type="radio" id="star2" name="rating" value="2"><label for="star2" class="bi bi-star-fill"></label>
                                        <input type="radio" id="star1" name="rating" value="1"><label for="star1" class="bi bi-star-fill"></label>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label text-muted">Review Details:</label>
                                    <textarea name="reviewText" class="form-control" rows="4" placeholder="Share your experience with this product..." required></textarea>
                                </div>

                                <button type="submit" class="btn btn-primary w-100">Submit Review</button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-3">
                                <p class="text-muted mb-3">You must be logged in to write reviews.</p>
                                <a href="login.jsp" class="btn btn-outline-light btn-sm">Login Now</a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Customer Reviews List -->
            <div class="col-lg-8">
                <div class="glass-panel h-100">
                    <h5 class="text-white mb-4"><i class="bi bi-people text-indigo"></i> Customer Reviews (${reviews.size()})</h5>
                    
                    <c:choose>
                        <c:when test="${empty reviews}">
                            <div class="text-center py-5">
                                <i class="bi bi-chat-square-dots fs-1 text-muted mb-2 d-block"></i>
                                <p class="text-muted">No reviews yet for this product. Be the first to share your thoughts!</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="review-list" style="max-height: 450px; overflow-y: auto;">
                                <c:forEach var="rev" items="${reviews}">
                                    <div class="mb-3 p-3" style="background: rgba(255,255,255,0.02); border: 1px solid var(--panel-border); border-radius: 8px;">
                                        <div class="d-flex justify-content-between mb-2">
                                            <h6 class="text-white mb-0"><c:out value="${rev.userName}" /></h6>
                                            <span class="text-muted small">${rev.createdAt}</span>
                                        </div>
                                        
                                        <!-- Stars rating -->
                                        <div class="text-warning mb-2" style="font-size: 0.85rem;">
                                            <c:forEach var="i" begin="1" end="5">
                                                <i class="bi ${i <= rev.rating ? 'bi-star-fill' : 'bi-star'}"></i>
                                            </c:forEach>
                                        </div>

                                        <p class="text-light mb-0 small" style="line-height: 1.5;"><c:out value="${rev.reviewText}" /></p>
                                    </div>
                                </c:forEach>
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
