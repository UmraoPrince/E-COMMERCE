<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>
<%@ page import="com.ecommerce.model.CartItem" %>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
    HttpSession checkSession = request.getSession(false);
    User userDetails = (checkSession != null) ? (User) checkSession.getAttribute("user") : null;
    if (userDetails == null) {
        response.sendRedirect("login.jsp?error=Authentication+required");
        return;
    }
    CartDAO cartDAO = new CartDAO();
    List<CartItem> checkItems = cartDAO.getCartItems(userDetails.getUserId());
    if (checkItems.isEmpty()) {
        response.sendRedirect("cart.jsp");
        return;
    }
    
    BigDecimal totalSum = BigDecimal.ZERO;
    for (CartItem item : checkItems) {
        totalSum = totalSum.add(item.getSubtotal());
    }
    
    request.setAttribute("cartItems", checkItems);
    request.setAttribute("cartTotal", totalSum);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy - Checkout</title>
    <style>
        .payment-card {
            background: rgba(255, 255, 255, 0.45);
            border: 2px solid rgba(0, 0, 0, 0.08);
            border-radius: 16px;
            cursor: pointer;
            transition: all 0.25s ease;
        }
        .payment-card:hover {
            border-color: var(--accent-color);
            transform: translateY(-2px);
            background: rgba(255, 255, 255, 0.7);
        }
        .payment-card.active {
            border-color: var(--accent-color);
            background: rgba(99, 102, 241, 0.1);
            box-shadow: 0 0 15px rgba(99, 102, 241, 0.15);
        }
        .cursor-pointer {
            cursor: pointer;
        }
        .trust-badge {
            background: rgba(255, 255, 255, 0.5);
            border: 1px solid rgba(255, 255, 255, 0.8);
            border-radius: 12px;
            padding: 8px 12px;
            font-size: 0.8rem;
            color: #555555;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
    </style>
</head>
<body>
    <%@ include file="components/navbar.jsp" %>

    <div class="container mt-5">
        <h3 class="text-white mb-4"><i class="bi bi-credit-card-2-front text-indigo"></i> Checkout</h3>
        
        <!-- Error Alert -->
        <c:if test="${not empty error}">
            <div class="custom-alert-error text-center">
                <i class="bi bi-exclamation-triangle-fill me-1"></i> <c:out value="${error}" />
            </div>
        </c:if>

        <div class="row">
            <!-- Order Summary Details -->
            <div class="col-lg-6 mb-4">
                <div class="glass-panel">
                    <h5 class="text-white mb-3"><i class="bi bi-bag-check text-indigo"></i> Review Items</h5>
                    <div class="table-responsive">
                        <table class="table text-white mb-0">
                            <thead>
                                <tr>
                                    <th>Item</th>
                                    <th class="text-center">Qty</th>
                                    <th class="text-end">Price</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${cartItems}">
                                    <tr>
                                        <td><c:out value="${item.productName}" /></td>
                                        <td class="text-center">${item.quantity}</td>
                                        <td class="text-end text-success">₹<c:out value="${item.subtotal}" /></td>
                                    </tr>
                                </c:forEach>
                                <tr class="fw-bold">
                                    <td class="text-muted border-top border-secondary">Total Amount</td>
                                    <td class="border-top border-secondary"></td>
                                    <td class="text-end text-success border-top border-secondary" style="font-size: 1.1rem;">
                                        ₹<c:out value="${cartTotal}" />
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Shipping & Payment Details -->
            <div class="col-lg-6">
                <div class="glass-panel">
                    <h5 class="text-white mb-3"><i class="bi bi-truck text-indigo"></i> Shipping & Payment</h5>
                    
                    <form action="order" method="POST">
                        <input type="hidden" name="action" value="place">
                        
                        <!-- CSRF Token -->
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

                        <div class="mb-3">
                            <label class="form-label text-muted">Delivery Address *</label>
                            <textarea name="address" class="form-control" rows="3" required placeholder="Enter complete shipping address..."><c:out value="${sessionScope.user.address}" /></textarea>
                            <div class="form-text text-muted small">We will deliver items to this physical address.</div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label text-muted mb-2 d-block">Payment Method</label>
                            <input type="hidden" name="paymentMethod" id="paymentMethodInput" value="COD">
                            
                            <div class="row g-3">
                                <!-- COD Card -->
                                <div class="col-md-6">
                                    <div class="payment-card active p-3 text-center cursor-pointer" id="cardCOD" onclick="selectPaymentMethod('COD')">
                                        <div class="fs-1 mb-2">💵</div>
                                        <div class="fw-bold">Cash on Delivery</div>
                                        <small class="text-muted">Pay with cash upon arrival</small>
                                    </div>
                                </div>
                                <!-- Online Card -->
                                <div class="col-md-6">
                                    <div class="payment-card p-3 text-center cursor-pointer" id="cardONLINE" onclick="selectPaymentMethod('ONLINE')">
                                        <div class="fs-1 mb-2">💳</div>
                                        <div class="fw-bold">Online Payment</div>
                                        <small class="text-muted">Simulate card/net banking</small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-3">
                            <i class="bi bi-shield-check"></i> Place Secure Order (₹<c:out value="${cartTotal}" />)
                        </button>

                        <div class="row g-2 mt-4 text-center">
                            <div class="col-6 col-md-3">
                                <div class="trust-badge w-100 justify-content-center">
                                    <span>🔒</span> <span>Secure Checkout</span>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="trust-badge w-100 justify-content-center">
                                    <span>🛡</span> <span>SSL Protected</span>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="trust-badge w-100 justify-content-center">
                                    <span>✅</span> <span>Verified Seller</span>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="trust-badge w-100 justify-content-center">
                                    <span>🚚</span> <span>Fast Delivery</span>
                                </div>
                            </div>
                        </div>
                    </form>
                    <script>
                        function selectPaymentMethod(method) {
                            document.getElementById('paymentMethodInput').value = method;
                            document.getElementById('cardCOD').classList.remove('active');
                            document.getElementById('cardONLINE').classList.remove('active');
                            document.getElementById('card' + method).classList.add('active');
                        }
                    </script>
                </div>
            </div>
        </div>
    </div>

    <!-- Core Scripting Dependencies -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
