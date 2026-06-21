<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.ecommerce.dao.OrderDAO" %>
<%@ page import="com.ecommerce.model.Order" %>
<%@ page import="com.ecommerce.model.OrderItem" %>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="java.util.List" %>
<%
    HttpSession checkSession = request.getSession(false);
    User userDetails = (checkSession != null) ? (User) checkSession.getAttribute("user") : null;
    if (userDetails == null) {
        response.sendRedirect("login.jsp?error=Authentication+required");
        return;
    }

    String orderIdStr = request.getParameter("orderId");
    if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
        response.sendRedirect("orders.jsp");
        return;
    }

    int orderId = Integer.parseInt(orderIdStr);
    OrderDAO orderDAO = new OrderDAO();
    Order order = orderDAO.getOrderById(orderId);

    // Security: Only allow admins or the order owner to view the invoice
    if (order == null || (!"ADMIN".equals(userDetails.getRole()) && order.getUserId() != userDetails.getUserId())) {
        response.sendRedirect("orders.jsp");
        return;
    }

    List<OrderItem> orderItems = orderDAO.getOrderItems(orderId);
    request.setAttribute("order", order);
    request.setAttribute("orderItems", orderItems);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy - Invoice #<c:out value="${order.orderId}"/></title>
    <style>
        .invoice-card {
            max-width: 800px;
            margin: 30px auto;
            background: rgba(255, 255, 255, 0.8) !important;
            border: 1px solid rgba(255, 255, 255, 0.9);
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            border-radius: 12px;
            padding: 40px;
            color: #333333;
        }
        .invoice-header {
            border-bottom: 2px solid rgba(0, 0, 0, 0.08);
            padding-bottom: 20px;
            margin-bottom: 20px;
        }
        .brand-logo {
            font-family: 'Outfit', sans-serif;
            font-weight: 800;
            font-size: 2rem;
            color: #2D2D2D;
        }
        .brand-logo span {
            color: var(--accent-color);
        }
        .invoice-details-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }
        .invoice-details-column p {
            margin: 4px 0;
        }
        .invoice-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }
        .invoice-table th {
            border-bottom: 2px solid rgba(0,0,0,0.1);
            padding: 10px;
            text-align: left;
            font-weight: 600;
        }
        .invoice-table td {
            border-bottom: 1px solid rgba(0,0,0,0.05);
            padding: 12px 10px;
        }
        .invoice-total-section {
            display: flex;
            justify-content: flex-end;
            margin-top: 20px;
        }
        .invoice-total-box {
            width: 250px;
        }
        .invoice-total-row {
            display: flex;
            justify-content: space-between;
            padding: 6px 0;
        }
        .invoice-total-row.grand-total {
            border-top: 2px solid rgba(0,0,0,0.1);
            font-weight: bold;
            font-size: 1.1rem;
            padding-top: 10px;
        }
        
        /* Print rules */
        @media print {
            body {
                background: none !important;
                background-color: #ffffff !important;
                color: #000000 !important;
                padding-bottom: 0 !important;
            }
            .no-print {
                display: none !important;
            }
            .invoice-card {
                max-width: 100% !important;
                margin: 0 !important;
                box-shadow: none !important;
                border: none !important;
                background: none !important;
                padding: 0 !important;
            }
            .invoice-table td, .invoice-table th {
                border-color: #ddd !important;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar hidden during print -->
    <div class="no-print">
        <%@ include file="components/navbar.jsp" %>
        <div class="container mt-4 text-center">
            <div class="d-flex justify-content-between align-items-center max-width-800 mx-auto" style="max-width: 800px;">
                <a href="orders.jsp" class="btn btn-outline-light btn-sm">
                    <i class="bi bi-arrow-left"></i> Back to Orders
                </a>
                <button onclick="window.print();" class="btn btn-primary btn-sm">
                    <i class="bi bi-printer"></i> Print / Download Invoice PDF
                </button>
            </div>
        </div>
    </div>

    <!-- Printable Invoice Card -->
    <div class="container">
        <div class="invoice-card">
            <!-- Header -->
            <div class="invoice-header d-flex justify-content-between align-items-center">
                <div>
                    <div class="brand-logo">Shop<span>Easy</span></div>
                    <p class="text-muted small mb-0">Secure Online E-Commerce Platform</p>
                </div>
                <div class="text-end">
                    <h3 class="mb-1 text-dark">INVOICE</h3>
                    <p class="mb-0 text-muted small">Invoice #: <strong>INV-<c:out value="${order.orderId}"/></strong></p>
                    <p class="mb-0 text-muted small">Date: <c:out value="${order.orderDate}"/></p>
                </div>
            </div>

            <!-- Details -->
            <div class="invoice-details-grid">
                <div class="invoice-details-column">
                    <h6 class="fw-bold text-uppercase small text-muted mb-2">Billed To:</h6>
                    <p class="fw-bold mb-1"><c:out value="${sessionScope.user.name}"/></p>
                    <p class="small text-muted mb-1"><c:out value="${sessionScope.user.email}"/></p>
                    <p class="small text-muted mb-1">Mob: <c:out value="${sessionScope.user.mobile}"/></p>
                </div>
                <div class="invoice-details-column">
                    <h6 class="fw-bold text-uppercase small text-muted mb-2">Shipping Address:</h6>
                    <p class="small mb-1"><c:out value="${order.shippingAddress}"/></p>
                    
                    <h6 class="fw-bold text-uppercase small text-muted mt-3 mb-2">Transaction Details:</h6>
                    <p class="small mb-1">Method: <strong class="text-uppercase"><c:out value="${order.paymentMethod}"/></strong></p>
                    <p class="small mb-1">Transaction ID: <span class="font-monospace text-muted"><c:out value="${order.transactionId}"/></span></p>
                    <p class="small mb-1">Payment Status: 
                        <c:choose>
                            <c:when test="${order.paymentStatus eq 'SUCCESSFUL'}">
                                <span class="badge bg-success small">SUCCESSFUL</span>
                            </c:when>
                            <c:when test="${order.paymentStatus eq 'FAILED'}">
                                <span class="badge bg-danger small">FAILED</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-warning text-dark small"><c:out value="${order.paymentStatus}"/></span>
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </div>

            <!-- Items -->
            <table class="invoice-table">
                <thead>
                    <tr>
                        <th>Product / Item Description</th>
                        <th class="text-end" style="width: 120px;">Unit Price</th>
                        <th class="text-center" style="width: 80px;">Qty</th>
                        <th class="text-end" style="width: 150px;">Total</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${orderItems}">
                        <tr>
                            <td>
                                <div class="fw-bold"><c:out value="${item.productName}"/></div>
                                <small class="text-muted">Item ID: #<c:out value="${item.productId}"/></small>
                            </td>
                            <td class="text-end">₹<c:out value="${item.price}"/></td>
                            <td class="text-center"><c:out value="${item.quantity}"/></td>
                            <td class="text-end fw-bold text-success">₹<c:out value="${item.price * item.quantity}"/></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <!-- Total -->
            <div class="invoice-total-section">
                <div class="invoice-total-box">
                    <div class="invoice-total-row">
                        <span class="text-muted">Subtotal:</span>
                        <span class="fw-bold">₹<c:out value="${order.totalAmount}"/></span>
                    </div>
                    <div class="invoice-total-row">
                        <span class="text-muted">Delivery Charges:</span>
                        <span class="text-success fw-bold">FREE</span>
                    </div>
                    <div class="invoice-total-row grand-total">
                        <span>Grand Total:</span>
                        <span class="text-success">₹<c:out value="${order.totalAmount}"/></span>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <div class="text-center mt-5 pt-4 border-top border-light text-muted small">
                <p class="mb-1">Thank you for shopping at ShopEasy!</p>
                <p class="mb-0">This is a computer-generated simulated receipt invoice. No signature required.</p>
            </div>
        </div>
    </div>

    <!-- Core Scripting Dependencies -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
