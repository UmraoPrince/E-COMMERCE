<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // Safely redirect direct JSP accesses to the servlet controller so databases are queried
    if (request.getAttribute("users") == null) {
        response.sendRedirect("users");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy Admin - User Accounts</title>
</head>
<body>
    <%@ include file="../components/admin_navbar.jsp" %>

    <div class="container-fluid py-4 px-4">
        <h3 class="text-white mb-4"><i class="bi bi-people text-warning"></i> Customer Accounts Registry</h3>

        <div class="glass-panel">
            <div class="table-responsive">
                <table class="table text-white mb-0" style="vertical-align: middle;">
                    <thead>
                        <tr>
                            <th>User ID</th>
                            <th>Name</th>
                            <th>Email Address</th>
                            <th>Mobile</th>
                            <th>Role</th>
                            <th>Shipping Address</th>
                            <th>Registered On</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="u" items="${users}">
                            <tr>
                                <td>#${u.userId}</td>
                                <td class="fw-bold"><c:out value="${u.name}" /></td>
                                <td><c:out value="${u.email}" /></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty u.mobile}">
                                            <c:out value="${u.mobile}" />
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted small">Not provided</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span class="badge ${u.role == 'ADMIN' ? 'bg-warning text-dark' : 'bg-primary'}">
                                        <c:out value="${u.role}" />
                                    </span>
                                </td>
                                <td class="small" style="max-width: 280px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                    <c:choose>
                                        <c:when test="${not empty u.address}">
                                            <c:out value="${u.address}" />
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted small">Not provided</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="small text-muted">${u.createdAt}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Core Scripting Dependencies -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
