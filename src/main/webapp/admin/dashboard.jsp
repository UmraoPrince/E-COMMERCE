<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy Admin - Dashboard</title>
</head>
<body>
    <%@ include file="../components/admin_navbar.jsp" %>
    
    <div class="container-fluid py-4 px-4">
        <!-- Header with Export Actions -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="text-white mb-0"><i class="bi bi-speedometer2 text-warning"></i> Administrative Overview Dashboard</h3>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/admin/export?format=PDF" target="_blank" class="btn btn-outline-light btn-sm">
                    <i class="bi bi-file-earmark-pdf-fill text-danger"></i> Export PDF Report
                </a>
                <a href="${pageContext.request.contextPath}/admin/export?format=XLS" class="btn btn-outline-light btn-sm">
                    <i class="bi bi-file-earmark-excel-fill text-success"></i> Export Excel (CSV)
                </a>
            </div>
        </div>
        
        <!-- Metrics Row -->
        <div class="row mb-4">
            <!-- Total Users Card -->
            <div class="col-md-3 mb-3">
                <div class="glass-panel text-center py-4" style="border-left: 4px solid var(--accent-color);">
                    <i class="bi bi-people text-indigo fs-2 mb-2"></i>
                    <h6 class="text-muted text-uppercase small">Total Customers</h6>
                    <h3 class="text-white mb-0 fw-bold">${stats.totalUsers}</h3>
                </div>
            </div>
            
            <!-- Total Revenue Card -->
            <div class="col-md-3 mb-3">
                <div class="glass-panel text-center py-4" style="border-left: 4px solid var(--success-color);">
                    <i class="bi bi-currency-rupee text-success fs-2 mb-2"></i>
                    <h6 class="text-muted text-uppercase small">Total Revenue</h6>
                    <h3 class="text-white mb-0 fw-bold">₹${stats.revenue}</h3>
                </div>
            </div>

            <!-- Total Orders Card -->
            <div class="col-md-3 mb-3">
                <div class="glass-panel text-center py-4" style="border-left: 4px solid var(--warning-color);">
                    <i class="bi bi-receipt text-warning fs-2 mb-2"></i>
                    <h6 class="text-muted text-uppercase small">Total Orders</h6>
                    <h3 class="text-white mb-0 fw-bold">${stats.totalOrders}</h3>
                </div>
            </div>

            <!-- Total Products Card -->
            <div class="col-md-3 mb-3">
                <div class="glass-panel text-center py-4" style="border-left: 4px solid #06b6d4;">
                    <i class="bi bi-box-seam text-info fs-2 mb-2"></i>
                    <h6 class="text-muted text-uppercase small">Total Products</h6>
                    <h3 class="text-white mb-0 fw-bold">${stats.totalProducts}</h3>
                </div>
            </div>
        </div>
        
        <!-- Payment Metrics Row -->
        <div class="row mb-4">
            <!-- Total Payments Card -->
            <div class="col-md-3 mb-3">
                <div class="glass-panel text-center py-4" style="border-left: 4px solid var(--accent-color);">
                    <i class="bi bi-wallet2 text-indigo fs-2 mb-2"></i>
                    <h6 class="text-muted text-uppercase small">Total Transactions</h6>
                    <h3 class="text-white mb-0 fw-bold">${payStats.totalPayments}</h3>
                </div>
            </div>
            
            <!-- Successful Payments Card -->
            <div class="col-md-3 mb-3">
                <div class="glass-panel text-center py-4" style="border-left: 4px solid var(--success-color);">
                    <i class="bi bi-check-circle text-success fs-2 mb-2"></i>
                    <h6 class="text-muted text-uppercase small">Successful Payments</h6>
                    <h3 class="text-white mb-0 fw-bold">${payStats.successPayments}</h3>
                </div>
            </div>

            <!-- Pending Payments Card -->
            <div class="col-md-3 mb-3">
                <div class="glass-panel text-center py-4" style="border-left: 4px solid var(--warning-color);">
                    <i class="bi bi-hourglass-split text-warning fs-2 mb-2"></i>
                    <h6 class="text-muted text-uppercase small">Pending Payments</h6>
                    <h3 class="text-white mb-0 fw-bold">${payStats.pendingPayments}</h3>
                </div>
            </div>

            <!-- Failed Payments Card -->
            <div class="col-md-3 mb-3">
                <div class="glass-panel text-center py-4" style="border-left: 4px solid var(--danger-color);">
                    <i class="bi bi-x-circle text-danger fs-2 mb-2"></i>
                    <h6 class="text-muted text-uppercase small">Failed Payments</h6>
                    <h3 class="text-white mb-0 fw-bold">${payStats.failedPayments}</h3>
                </div>
            </div>
        </div>
        
        <div class="row mb-4">
            <!-- Low Stock Warnings Panel -->
            <div class="col-md-6 mb-4">
                <div class="glass-panel h-100">
                    <h5 class="text-danger mb-4"><i class="bi bi-exclamation-triangle-fill"></i> Low Stock Alerts (Stock &le; 5)</h5>
                    <div class="table-responsive">
                        <table class="table text-white mb-0 small" style="vertical-align: middle;">
                            <thead>
                                <tr>
                                    <th>Product Name</th>
                                    <th>Remaining Stock</th>
                                    <th class="text-center">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty lowStockProducts}">
                                        <tr>
                                            <td colspan="3" class="text-center text-muted py-4">All products are adequately stocked.</td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="p" items="${lowStockProducts}">
                                            <tr>
                                                <td><c:out value="${p.productName}" /></td>
                                                <td class="text-danger fw-bold">${p.stock}</td>
                                                <td class="text-center">
                                                    <a href="editProduct.jsp?id=${p.productId}" class="btn btn-sm btn-warning">
                                                        <i class="bi bi-plus-circle"></i> Restock
                                                    </a>
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

            <!-- Operations guide card -->
            <div class="col-md-6 mb-4">
                <div class="glass-panel h-100 d-flex flex-column justify-content-between">
                    <div>
                        <h5 class="text-white mb-3"><i class="bi bi-info-circle text-warning"></i> Quick Operations Guide</h5>
                        <p class="text-muted small">You are logged in as a Store Administrator. Use the navbar to access specific tools:</p>
                        <ul class="text-light small" style="line-height: 1.8;">
                            <li><strong>Products Manager</strong>: Add new products, upload images, adjust catalog prices, or delete items.</li>
                            <li><strong>Orders Ledger</strong>: Review customer invoice transactions and update shipping statuses (PENDING &rarr; DELIVERED).</li>
                            <li><strong>User Accounts</strong>: View details of registered customer profiles.</li>
                        </ul>
                    </div>
                    <div class="mt-3">
                        <span class="text-muted small">Current Server Time: <%= new java.util.Date() %></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Payment History Table Row -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="glass-panel">
                    <h5 class="text-white mb-4"><i class="bi bi-wallet2 text-indigo"></i> Payment Transaction Ledger</h5>
                    <div class="table-responsive">
                        <table class="table text-white mb-0 small" style="vertical-align: middle;">
                            <thead>
                                <tr>
                                    <th>Payment ID</th>
                                    <th>Order ID</th>
                                    <th>Customer</th>
                                    <th>Payment Method</th>
                                    <th>Transaction ID</th>
                                    <th>Amount</th>
                                    <th>Date</th>
                                    <th>Payment Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty paymentHistory}">
                                        <tr>
                                            <td colspan="8" class="text-center text-muted py-4">No transactions logged.</td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="p" items="${paymentHistory}">
                                            <tr>
                                                <td>#${p.paymentId}</td>
                                                <td>#${p.orderId}</td>
                                                <td><c:out value="${p.userName}"/></td>
                                                <td class="text-uppercase fw-bold">${p.paymentMethod}</td>
                                                <td class="font-monospace text-muted small"><c:out value="${p.transactionId}"/></td>
                                                <td class="text-success fw-bold">₹<c:out value="${p.amount}"/></td>
                                                <td class="small">${p.paymentDate}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${p.paymentStatus == 'SUCCESSFUL'}">
                                                            <span class="badge bg-success">Successful</span>
                                                        </c:when>
                                                        <c:when test="${p.paymentStatus == 'FAILED'}">
                                                            <span class="badge bg-danger">Failed</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-warning text-dark">${p.paymentStatus}</span>
                                                        </c:otherwise>
                                                    </c:choose>
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
        </div>
    </div>

    <!-- Core Scripting Dependencies -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
