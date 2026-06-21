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
    if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
        response.sendRedirect("orders.jsp");
        return;
    }

    int orderId = Integer.parseInt(orderIdStr);
    OrderDAO orderDAO = new OrderDAO();
    Order order = orderDAO.getOrderById(orderId);

    if (order == null || order.getUserId() != userDetails.getUserId()) {
        response.sendRedirect("orders.jsp");
        return;
    }

    // If order is already paid, redirect to success
    if ("CONFIRMED".equals(order.getStatus()) && !"PENDING".equals(order.getPaymentStatus())) {
        response.sendRedirect("order-success.jsp?orderId=" + orderId);
        return;
    }

    request.setAttribute("order", order);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy - Secure Payment Gateway</title>
    <style>
        .payment-container {
            max-width: 600px;
            margin: 40px auto;
        }
        .spinner-wrapper {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 250px;
        }
        .loader-ring {
            display: inline-block;
            width: 80px;
            height: 80px;
            border: 6px solid rgba(99, 102, 241, 0.1);
            border-radius: 50%;
            border-top-color: var(--accent-color);
            animation: spin 1s ease-in-out infinite;
            margin-bottom: 20px;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        .step-panel {
            display: none;
        }
        .step-panel.active {
            display: block;
        }
        .success-icon-container {
            font-size: 4rem;
            color: var(--success-color);
            margin-bottom: 20px;
        }
        .failure-icon-container {
            font-size: 4rem;
            color: var(--danger-color);
            margin-bottom: 20px;
        }
        .txn-detail-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }
        .txn-detail-row:last-child {
            border-bottom: none;
        }
    </style>
</head>
<body>
    <%@ include file="components/navbar.jsp" %>

    <div class="container">
        <div class="payment-container">
            <div class="glass-panel text-center p-5">
                
                <!-- STEP 1: SUMMARY -->
                <div id="stepSummary" class="step-panel active">
                    <div class="mb-4">
                        <span class="fs-1">🔒</span>
                        <h3 class="text-white mt-2">Secure Online Payment</h3>
                        <p class="text-muted small">ShopEasy Payment Gateway Simulation</p>
                    </div>

                    <div class="card p-4 mb-4 text-start">
                        <div class="txn-detail-row">
                            <span class="text-muted">Order ID:</span>
                            <span class="fw-bold">#<c:out value="${order.orderId}"/></span>
                        </div>
                        <div class="txn-detail-row">
                            <span class="text-muted">Transaction ID:</span>
                            <span class="font-monospace text-muted small"><c:out value="${order.transactionId}"/></span>
                        </div>
                        <div class="txn-detail-row">
                            <span class="text-muted">Customer:</span>
                            <span class="fw-bold"><c:out value="${sessionScope.user.name}"/></span>
                        </div>
                        <div class="txn-detail-row">
                            <span class="text-muted">Total Amount:</span>
                            <span class="text-success fw-bold fs-5">₹<c:out value="${order.totalAmount}"/></span>
                        </div>
                    </div>

                    <div class="alert alert-info py-2 px-3 mb-4 text-start small">
                        <i class="bi bi-info-circle-fill"></i> <strong>Simulation Note:</strong> Clicking "Proceed to Pay" will trigger a simulated credit card authorization flow.
                    </div>

                    <button type="button" class="btn btn-primary w-100 py-3 fs-6" onclick="startPaymentProcess()">
                        <i class="bi bi-credit-card-2-back-fill"></i> Proceed to Pay (₹<c:out value="${order.totalAmount}"/>)
                    </button>
                </div>

                <!-- STEP 2: PROCESSING (SPINNER) -->
                <div id="stepProcessing" class="step-panel">
                    <div class="spinner-wrapper">
                        <div class="loader-ring"></div>
                        <h4 class="text-white">Processing Payment...</h4>
                        <p class="text-muted small">Connecting with securely encrypted bank gateway. Do not refresh or go back.</p>
                    </div>
                </div>

                <!-- STEP 3: SUCCESS SCREEN -->
                <div id="stepSuccess" class="step-panel">
                    <div class="success-icon-container">
                        <i class="bi bi-check-circle-fill"></i>
                    </div>
                    <h3 class="text-success mb-2">Payment Successful!</h3>
                    <p class="text-muted mb-4">Your order has been confirmed and is now processing.</p>

                    <div class="card p-4 mb-4 text-start">
                        <div class="txn-detail-row">
                            <span class="text-muted">Payment Status:</span>
                            <span class="badge bg-success">SUCCESSFUL</span>
                        </div>
                        <div class="txn-detail-row">
                            <span class="text-muted">Transaction ID:</span>
                            <span class="font-monospace text-muted small" id="successTxnId"><c:out value="${order.transactionId}"/></span>
                        </div>
                        <div class="txn-detail-row">
                            <span class="text-muted">Amount Paid:</span>
                            <span class="text-success fw-bold">₹<c:out value="${order.totalAmount}"/></span>
                        </div>
                    </div>

                    <div class="d-flex gap-3">
                        <a href="invoice.jsp?orderId=${order.orderId}" target="_blank" class="btn btn-outline-light w-50 py-3">
                            <i class="bi bi-file-earmark-pdf-fill text-danger"></i> Print Invoice
                        </a>
                        <a href="orders.jsp" class="btn btn-primary w-50 py-3">
                            <i class="bi bi-bag-check-fill"></i> View My Orders
                        </a>
                    </div>
                </div>

                <!-- STEP 4: FAILURE SCREEN -->
                <div id="stepFailure" class="step-panel">
                    <div class="failure-icon-container">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                    </div>
                    <h3 class="text-danger mb-2">Payment Failed</h3>
                    <p class="text-muted mb-4">The bank transaction was declined.</p>

                    <div class="card p-4 mb-4 text-start">
                        <div class="txn-detail-row">
                            <span class="text-muted">Payment Status:</span>
                            <span class="badge bg-danger">DECLINED</span>
                        </div>
                        <div class="txn-detail-row">
                            <span class="text-muted">Reason:</span>
                            <span class="text-danger fw-bold" id="failureReason">Bank server timeout</span>
                        </div>
                    </div>

                    <div class="d-flex gap-3">
                        <a href="checkout.jsp" class="btn btn-outline-light w-50 py-3">
                            <i class="bi bi-arrow-left"></i> Back to Checkout
                        </a>
                        <button type="button" class="btn btn-primary w-50 py-3" onclick="resetToSummary()">
                            <i class="bi bi-arrow-clockwise"></i> Retry Payment
                        </button>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <!-- Core Scripting Dependencies -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
    
    <script>
        function showStep(stepId) {
            $('.step-panel').removeClass('active');
            $('#' + stepId).addClass('active');
        }

        function resetToSummary() {
            showStep('stepSummary');
        }

        function startPaymentProcess() {
            // Transition to processing spinner
            showStep('stepProcessing');

            // Wait 2.5 seconds, then simulate the payment
            setTimeout(function() {
                // 90% Success, 10% Failure
                var randomRoll = Math.random();
                var paymentSuccess = randomRoll < 0.90;

                var finalStatus = paymentSuccess ? 'SUCCESSFUL' : 'FAILED';
                var reasons = [
                    "Bank Server Connection Timeout",
                    "Insufficient Funds in Account",
                    "Card Authorization Declined by Issuer",
                    "Incorrect Secure OTP Pin Code Entered",
                    "Transaction Flagged as Suspicious"
                ];
                var randomReason = reasons[Math.floor(Math.random() * reasons.length)];

                // Report callback status back to backend via AJAX
                $.ajax({
                    url: '${pageContext.request.contextPath}/payment-callback',
                    type: 'POST',
                    data: {
                        orderId: '${order.orderId}',
                        status: finalStatus,
                        csrfToken: '${sessionScope.csrfToken}'
                    },
                    success: function(response) {
                        if (response.success) {
                            if (paymentSuccess) {
                                showStep('stepSuccess');
                            } else {
                                $('#failureReason').text(randomReason);
                                showStep('stepFailure');
                            }
                        } else {
                            // Fallback if backend update failed
                            $('#failureReason').text("Database Synch Error: " + response.message);
                            showStep('stepFailure');
                        }
                    },
                    error: function(xhr, status, error) {
                        $('#failureReason').text("Network Callback Interruption: " + error);
                        showStep('stepFailure');
                    }
                });

            }, 2500);
        }
    </script>
</body>
</html>
