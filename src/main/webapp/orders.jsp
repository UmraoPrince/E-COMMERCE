<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.ecommerce.dao.OrderDAO" %>
<%@ page import="com.ecommerce.model.Order" %>
<%@ page import="com.ecommerce.model.OrderItem" %>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="java.util.List" %>
<%
    HttpSession orderCheckSession = request.getSession(false);
    User userInst = (orderCheckSession != null) ? (User) orderCheckSession.getAttribute("user") : null;
    if (userInst == null) {
        response.sendRedirect("login.jsp?error=Authentication+required");
        return;
    }
    OrderDAO oDAO = new OrderDAO();
    List<Order> userOrdersList = oDAO.getUserOrders(userInst.getUserId());
    request.setAttribute("orders", userOrdersList);
    
    String viewIdStr = request.getParameter("viewId");
    if (viewIdStr != null && !viewIdStr.trim().isEmpty()) {
        try {
            int viewOrderId = Integer.parseInt(viewIdStr.trim());
            Order selectedOrder = oDAO.getOrderById(viewOrderId);
            if (selectedOrder != null && selectedOrder.getUserId() == userInst.getUserId()) {
                List<OrderItem> details = oDAO.getOrderItems(viewOrderId);
                request.setAttribute("selectedOrder", selectedOrder);
                request.setAttribute("orderDetails", details);
            }
        } catch (NumberFormatException e) {
            // ignore bad formatting
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy - My Purchase History</title>
</head>
<body>
    <%@ include file="components/navbar.jsp" %>

    <div class="container mt-5">
        <h3 class="text-white mb-4"><i class="bi bi-receipt text-indigo"></i> My Order History</h3>

        <c:choose>
            <c:when test="${empty orders}">
                <!-- Empty Orders State -->
                <div class="glass-panel text-center py-5">
                    <i class="bi bi-clock-history fs-1 text-muted mb-3 d-block" style="font-size: 4rem !important;"></i>
                    <h4 class="text-white">No orders placed yet</h4>
                    <p class="text-muted">You haven't ordered anything yet. Browse our catalog and place your first order!</p>
                    <a href="index.jsp" class="btn btn-primary px-4 mt-3">Browse Catalog</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="row">
                    <!-- Orders List Grid -->
                    <div class="col-lg-8 mb-4">
                        <div class="glass-panel table-responsive">
                            <table class="table text-white mb-0" style="vertical-align: middle;">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Transaction ID</th>
                                        <th>Date</th>
                                        <th>Payment</th>
                                        <th>Total</th>
                                        <th>Status</th>
                                        <th class="text-center">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="ord" items="${orders}">
                                        <tr class="${selectedOrder.orderId == ord.orderId ? 'table-active' : ''}">
                                            <td>#${ord.orderId}</td>
                                            <td class="font-monospace text-muted small"><c:out value="${ord.transactionId}"/></td>
                                            <td class="small">${ord.orderDate}</td>
                                            <td class="small">
                                                <strong class="text-uppercase"><c:out value="${ord.paymentMethod}"/></strong><br>
                                                <span class="badge ${ord.paymentStatus == 'SUCCESSFUL' ? 'bg-success' : 'bg-warning text-dark'} small" style="font-size:0.75rem;">
                                                    <c:out value="${ord.paymentStatus}"/>
                                                </span>
                                            </td>
                                            <td class="text-success fw-bold">₹<c:out value="${ord.totalAmount}" /></td>
                                            <td>
                                                <!-- Color-coded status badge -->
                                                <c:choose>
                                                    <c:when test="${ord.status == 'PENDING'}">
                                                        <span class="badge bg-warning text-dark">Pending</span>
                                                    </c:when>
                                                    <c:when test="${ord.status == 'CONFIRMED'}">
                                                        <span class="badge bg-primary">Confirmed</span>
                                                    </c:when>
                                                    <c:when test="${ord.status == 'SHIPPED'}">
                                                        <span class="badge bg-info">Shipped</span>
                                                    </c:when>
                                                    <c:when test="${ord.status == 'DELIVERED'}">
                                                        <span class="badge bg-success">Delivered</span>
                                                    </c:when>
                                                    <c:when test="${ord.status == 'CANCELLED'}">
                                                        <span class="badge bg-danger">Cancelled</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">${ord.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <div class="d-flex justify-content-center gap-1 flex-wrap">
                                                    <!-- View Items Details Button -->
                                                    <a href="orders.jsp?viewId=${ord.orderId}" class="btn btn-sm btn-primary">
                                                        <i class="bi bi-list-ul"></i> Items
                                                    </a>
                                                    
                                                    <!-- Print Invoice -->
                                                    <a href="invoice.jsp?orderId=${ord.orderId}" target="_blank" class="btn btn-sm btn-outline-light">
                                                        <i class="bi bi-file-earmark-pdf-fill text-danger"></i> Invoice
                                                    </a>

                                                    <!-- Pay Now (if pending/failed online order) -->
                                                    <c:if test="${ord.paymentMethod == 'ONLINE' && ord.paymentStatus != 'SUCCESSFUL' && ord.status == 'PENDING'}">
                                                        <a href="payment.jsp?orderId=${ord.orderId}" class="btn btn-sm btn-warning text-dark fw-bold">
                                                            <i class="bi bi-credit-card"></i> Pay
                                                        </a>
                                                    </c:if>
                                                    
                                                    <!-- Cancel button (only PENDING/CONFIRMED) -->
                                                    <c:if test="${ord.status == 'PENDING' || ord.status == 'CONFIRMED'}">
                                                        <form action="order" method="POST" onsubmit="return confirm('Are you sure you want to cancel this order?');" style="display:inline;">
                                                            <input type="hidden" name="action" value="cancel">
                                                            <input type="hidden" name="orderId" value="${ord.orderId}">
                                                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                            <button type="submit" class="btn btn-sm btn-danger">
                                                                <i class="bi bi-x-circle"></i> Cancel
                                                             </button>
                                                        </form>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
 
                    <!-- Selected Invoice breakdown panel -->
                    <div class="col-lg-4">
                        <c:choose>
                            <c:when test="${not empty selectedOrder}">
                                <div class="glass-panel">
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <h5 class="text-white mb-0">Order Invoice #${selectedOrder.orderId}</h5>
                                        <a href="orders.jsp" class="btn-close btn-close-white" aria-label="Close"></a>
                                    </div>
                                    <p class="text-muted small mb-3">Ordered on ${selectedOrder.orderDate}</p>
                                    
                                    <div class="mb-3 text-light small">
                                        <strong>Shipping Address:</strong><br>
                                        <c:out value="${selectedOrder.shippingAddress}" />
                                    </div>
 
                                    <div class="mb-3 text-light small">
                                        <strong>Transaction ID:</strong> <span class="font-monospace text-muted small"><c:out value="${selectedOrder.transactionId}" /></span>
                                    </div>

                                    <div class="mb-3 text-light small">
                                        <strong>Payment Method:</strong> <strong class="text-uppercase"><c:out value="${selectedOrder.paymentMethod}" /></strong> / 
                                        <strong>Payment Status:</strong> 
                                        <span class="badge ${selectedOrder.paymentStatus == 'SUCCESSFUL' ? 'bg-success' : 'bg-warning text-dark'}">
                                            <c:out value="${selectedOrder.paymentStatus}" />
                                        </span>
                                    </div>
 
                                    <hr style="background-color: var(--panel-border);">
 
                                    <h6 class="text-white mb-2">Order Content:</h6>
                                    <div class="table-responsive">
                                        <table class="table text-white mb-0 small">
                                            <thead>
                                                <tr>
                                                    <th>Product Name</th>
                                                    <th class="text-center">Qty</th>
                                                    <th class="text-end">Price</th>
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
                                                    <td>Invoice Grand Total</td>
                                                    <td></td>
                                                    <td class="text-end text-success">₹<c:out value="${selectedOrder.totalAmount}" /></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="glass-panel text-center py-5">
                                    <i class="bi bi-info-circle text-muted fs-2 mb-2 d-block"></i>
                                    <p class="text-muted">Click the "Items" button on any order to view purchase descriptions and delivery details.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
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
