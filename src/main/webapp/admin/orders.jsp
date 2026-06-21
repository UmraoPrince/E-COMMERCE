<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.ecommerce.dao.OrderDAO" %>
<%@ page import="com.ecommerce.model.Order" %>
<%@ page import="com.ecommerce.model.OrderItem" %>
<%@ page import="java.util.List" %>
<%
    // Safely redirect direct JSP accesses to the servlet controller so databases are queried
    if (request.getAttribute("orders") == null) {
        response.sendRedirect("orders");
        return;
    }
    
    String viewIdStr = request.getParameter("viewId");
    if (viewIdStr != null && !viewIdStr.trim().isEmpty()) {
        try {
            int viewOrderId = Integer.parseInt(viewIdStr.trim());
            OrderDAO oDAO = new OrderDAO();
            Order selectedOrder = oDAO.getOrderById(viewOrderId);
            if (selectedOrder != null) {
                List<OrderItem> details = oDAO.getOrderItems(viewOrderId);
                request.setAttribute("selectedOrder", selectedOrder);
                request.setAttribute("orderDetails", details);
            }
        } catch (NumberFormatException e) {
            // ignore
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy Admin - Order Operations</title>
</head>
<body>
    <%@ include file="../components/admin_navbar.jsp" %>

    <div class="container-fluid py-4 px-4">
        <h3 class="text-white mb-4"><i class="bi bi-receipt text-warning"></i> Order Operations Book</h3>

        <div class="row">
            <!-- Order List Table -->
            <div class="col-lg-8 mb-4">
                <div class="glass-panel table-responsive">
                    <table class="table text-white mb-0" style="vertical-align: middle;">
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Customer</th>
                                <th>Date</th>
                                <th>Amount</th>
                                <th>Method / Payment</th>
                                <th>Status Action</th>
                                <th>Items</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty orders}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">No order records found in ledger.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="ord" items="${orders}">
                                        <tr class="${selectedOrder.orderId == ord.orderId ? 'table-active' : ''}">
                                            <td>#${ord.orderId}</td>
                                            <td class="fw-bold"><c:out value="${ord.userName}" /></td>
                                            <td class="small">${ord.orderDate}</td>
                                            <td class="text-success fw-bold">₹<c:out value="${ord.totalAmount}" /></td>
                                            <td>
                                                <span class="small d-block text-muted">Method: <c:out value="${ord.paymentMethod}" /></span>
                                                <span class="badge ${ord.paymentStatus == 'SUCCESSFUL' || ord.paymentStatus == 'SUCCESS' ? 'bg-success' : 'bg-warning'}">
                                                    Payment: <c:out value="${ord.paymentStatus}" />
                                                </span>
                                            </td>
                                            <td>
                                                <!-- Dynamic inline order status update form -->
                                                <form action="${pageContext.request.contextPath}/order" method="POST" style="display:inline;">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="orderId" value="${ord.orderId}">
                                                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    
                                                    <select name="status" class="form-select form-select-sm border-0" onchange="this.form.submit();" style="width: 130px; background-color: rgba(255,255,255,0.08);">
                                                        <option value="PENDING" ${ord.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                                                        <option value="CONFIRMED" ${ord.status == 'CONFIRMED' ? 'selected' : ''}>Confirmed</option>
                                                        <option value="SHIPPED" ${ord.status == 'SHIPPED' ? 'selected' : ''}>Shipped</option>
                                                        <option value="OUT_FOR_DELIVERY" ${ord.status == 'OUT_FOR_DELIVERY' ? 'selected' : ''}>Out for Delivery</option>
                                                        <option value="DELIVERED" ${ord.status == 'DELIVERED' ? 'selected' : ''}>Delivered</option>
                                                        <option value="CANCELLED" ${ord.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                                                    </select>
                                                </form>
                                            </td>
                                            <td>
                                                <a href="orders?viewId=${ord.orderId}" class="btn btn-sm btn-primary py-1 px-2.5">
                                                    <i class="bi bi-receipt"></i> Details
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

            <!-- Detail breakdown sidebar -->
            <div class="col-lg-4">
                <c:choose>
                    <c:when test="${not empty selectedOrder}">
                        <div class="glass-panel">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5 class="text-white mb-0">Invoice #${selectedOrder.orderId}</h5>
                                <a href="orders" class="btn-close btn-close-white"></a>
                            </div>
                            <p class="text-muted small mb-3">Ordered on ${selectedOrder.orderDate}</p>

                            <div class="mb-3 text-light small">
                                <strong>Customer Profile:</strong><br>
                                <c:out value="${selectedOrder.userName}" /> (ID: #${selectedOrder.userId})
                            </div>
                            
                            <div class="mb-3 text-light small">
                                <strong>Shipping Address:</strong><br>
                                <c:out value="${selectedOrder.shippingAddress}" />
                            </div>

                            <hr style="background-color: var(--panel-border);">

                            <h6 class="text-white mb-2">Ordered Items:</h6>
                            <div class="table-responsive">
                                <table class="table text-white mb-0 small">
                                    <thead>
                                        <tr>
                                            <th>Item Name</th>
                                            <th class="text-center">Qty</th>
                                            <th class="text-end">Subtotal</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="oi" items="${orderDetails}">
                                            <tr>
                                                <td><c:out value="${oi.productName}" /></td>
                                                <td class="text-center">${oi.quantity}</td>
                                                <td class="text-end text-success">₹<c:out value="${oi.subtotal}" /></td>
                                            </tr>
                                        </c:forEach>
                                        <tr class="fw-bold">
                                            <td>Total Amount</td>
                                            <td></td>
                                            <td class="text-end text-success">₹<c:out value="${selectedOrder.totalAmount}" /></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="glass-panel text-center py-5 text-muted">
                            <i class="bi bi-info-circle fs-3 mb-2 d-block"></i>
                            <p>Click "Details" on any order row to review full purchase invoice summaries and customer shipping records.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Core Scripting Dependencies -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
