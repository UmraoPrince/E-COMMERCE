<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.ecommerce.dao.OrderDAO" %>
<%@ page import="com.ecommerce.model.Order" %>
<%@ page import="com.ecommerce.model.User" %>
<%
    HttpSession checkSession = request.getSession(false);
    User userDetails = (checkSession != null) ? (User) checkSession.getAttribute("user") : null;
    if (userDetails == null) {
        response.sendRedirect("login.jsp?error=Authentication+required");
        return;
    }

    String orderIdStr = request.getParameter("orderId");
    if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
        try {
            int orderId = Integer.parseInt(orderIdStr);
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.getOrderById(orderId);
            if (order != null && order.getUserId() == userDetails.getUserId()) {
                request.setAttribute("order", order);
                
                // Calculate expected delivery date: order_date + 4 days
                java.util.Calendar cal = java.util.Calendar.getInstance();
                cal.setTime(order.getOrderDate() != null ? order.getOrderDate() : new java.util.Date());
                cal.add(java.util.Calendar.DATE, 4);
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("EEEE, dd MMM yyyy");
                request.setAttribute("expectedDeliveryDate", sdf.format(cal.getTime()));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy - Order Success</title>
    <style>
        .txn-detail-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }
        .txn-detail-row:last-child {
            border-bottom: none;
        }
    </style>
</head>
<body>
    <%@ include file="components/navbar.jsp" %>

    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-7 text-center">
                <div class="glass-panel py-5">
                    <i class="bi bi-patch-check-fill text-success" style="font-size: 5rem; display: block; filter: drop-shadow(0 0 10px rgba(16, 185, 129, 0.4));"></i>
                    
                    <h2 class="text-white mt-4">Order Placed Successfully!</h2>
                    <p class="text-muted lead px-3 mt-2">Thank you for shopping with ShopEasy. Your order has been registered and is being processed by our store team.</p>
                    
                    <c:if test="${not empty order}">
                        <div class="card p-4 my-4 text-start mx-auto" style="max-width: 500px;">
                            <div class="txn-detail-row">
                                <span class="text-muted">Order ID:</span>
                                <span class="fw-bold">#<c:out value="${order.orderId}"/></span>
                            </div>
                            <div class="txn-detail-row">
                                <span class="text-muted">Transaction ID:</span>
                                <span class="font-monospace text-muted small"><c:out value="${order.transactionId}"/></span>
                            </div>
                            <div class="txn-detail-row">
                                <span class="text-muted">Amount:</span>
                                <span class="text-success fw-bold">₹<c:out value="${order.totalAmount}"/></span>
                            </div>
                            <div class="txn-detail-row">
                                <span class="text-muted">Payment Method:</span>
                                <span class="text-uppercase fw-bold"><c:out value="${order.paymentMethod}"/></span>
                            </div>
                            <div class="txn-detail-row">
                                <span class="text-muted">Expected Delivery:</span>
                                <span class="fw-bold" style="color: var(--accent-color) !important;"><c:out value="${expectedDeliveryDate}"/></span>
                            </div>
                        </div>
                    </c:if>
                    
                    <hr class="my-4 mx-5" style="background-color: var(--panel-border);">

                    <div class="d-flex justify-content-center gap-3">
                        <c:if test="${not empty order}">
                            <a href="invoice.jsp?orderId=${order.orderId}" target="_blank" class="btn btn-outline-light px-4 py-2.5">
                                <i class="bi bi-file-earmark-pdf-fill text-danger"></i> Print Invoice
                            </a>
                        </c:if>
                        <a href="orders.jsp" class="btn btn-primary px-4 py-2.5">
                            <i class="bi bi-receipt"></i> View My Orders
                        </a>
                        <a href="index.jsp" class="btn btn-outline-light px-4 py-2.5">
                            <i class="bi bi-shop"></i> Continue Shopping
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Core Scripting Dependencies -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
