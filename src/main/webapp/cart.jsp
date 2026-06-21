<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>
<%@ page import="com.ecommerce.model.CartItem" %>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
    HttpSession userSession = request.getSession(false);
    User userObj = (userSession != null) ? (User) userSession.getAttribute("user") : null;
    if (userObj == null) {
        response.sendRedirect("login.jsp?error=Authentication+required");
        return;
    }
    CartDAO cartDAO = new CartDAO();
    List<CartItem> cartItems = cartDAO.getCartItems(userObj.getUserId());
    
    BigDecimal cartTotal = BigDecimal.ZERO;
    for (CartItem item : cartItems) {
        cartTotal = cartTotal.add(item.getSubtotal());
    }
    
    request.setAttribute("cartItems", cartItems);
    request.setAttribute("cartTotal", cartTotal);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy - Shopping Cart</title>
</head>
<body>
    <%@ include file="components/navbar.jsp" %>
    <fmt:setLocale value="en_IN"/>

    <div class="container mt-5">
        <h3 class="text-white mb-4"><i class="bi bi-cart3 text-indigo"></i> My Shopping Cart</h3>

        <c:choose>
            <c:when test="${empty cartItems}">
                <!-- Empty Cart State -->
                <div class="glass-panel text-center py-5">
                    <i class="bi bi-bag-x fs-1 text-muted mb-3 d-block" style="font-size: 4rem !important;"></i>
                    <h4 class="text-white">Your cart is currently empty</h4>
                    <p class="text-muted">Looks like you haven't added any products to your cart yet.</p>
                    <a href="index.jsp" class="btn btn-primary px-4 mt-3">Start Shopping</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="row">
                    <!-- Cart Items List -->
                    <div class="col-lg-8 mb-4">
                        <div class="glass-panel table-responsive">
                            <table class="table text-white mb-0" style="vertical-align: middle;">
                                <thead>
                                    <tr>
                                        <th>Product</th>
                                        <th>Price</th>
                                        <th>Quantity</th>
                                        <th>Subtotal</th>
                                        <th>Remove</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="item" items="${cartItems}">
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <!-- Image preview -->
                                                    <c:choose>
                                                        <c:when test="${not empty item.productImage}">
                                                            <img src="${pageContext.request.contextPath}/${item.productImage}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 6px;" class="me-3" alt="Product">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="d-flex align-items-center justify-content-center text-muted bg-dark me-3" style="width: 50px; height: 50px; border-radius: 6px;">
                                                                <i class="bi bi-image"></i>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div>
                                                        <h6 class="mb-0 text-truncate" style="max-width: 180px;">
                                                            <a href="product-details.jsp?id=${item.productId}" class="text-white text-decoration-none"><c:out value="${item.productName}" /></a>
                                                        </h6>
                                                        <span class="text-muted small">${item.stock} in stock</span>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="text-light"><fmt:formatNumber value="${item.productPrice}" type="currency" currencySymbol="₹"/></td>
                                            <td>
                                                <!-- Quantity selector with stock check validation -->
                                                <input type="number" 
                                                       value="${item.quantity}" 
                                                       min="1" 
                                                       max="${item.stock}" 
                                                       class="form-control text-center" 
                                                       style="width: 75px;" 
                                                       onchange="updateCartQty(${item.productId}, this.value)">
                                            </td>
                                            <td class="text-success fw-bold"><fmt:formatNumber value="${item.subtotal}" type="currency" currencySymbol="₹"/></td>
                                            <td>
                                                <button class="btn btn-sm btn-danger" onclick="removeFromCart(${item.productId})">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Cart Summary panel -->
                    <div class="col-lg-4">
                        <div class="glass-panel">
                            <h5 class="text-white mb-4">Order Summary</h5>
                            
                            <div class="d-flex justify-content-between mb-2">
                                <span class="text-muted">Subtotal</span>
                                <span class="text-light"><fmt:formatNumber value="${cartTotal}" type="currency" currencySymbol="₹"/></span>
                            </div>
                            <div class="d-flex justify-content-between mb-3">
                                <span class="text-muted">Shipping</span>
                                <span class="text-success">FREE</span>
                            </div>
                            
                            <hr style="background-color: var(--panel-border);">
                            
                            <div class="d-flex justify-content-between mb-4">
                                <h5 class="text-white mb-0">Total</h5>
                                <h5 class="text-success mb-0"><fmt:formatNumber value="${cartTotal}" type="currency" currencySymbol="₹"/></h5>
                            </div>
                            
                            <a href="checkout.jsp" class="btn btn-primary w-100 py-2.5">
                                <i class="bi bi-credit-card-fill"></i> Proceed to Checkout
                            </a>
                            <a href="index.jsp" class="btn btn-outline-light w-100 mt-2">
                                <i class="bi bi-arrow-left"></i> Continue Shopping
                            </a>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Core Scripting Dependencies -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
