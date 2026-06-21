<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>NexusMarket Admin - Security Audit Logs</title>
</head>
<body>
    <%@ include file="../components/admin_navbar.jsp" %>

    <div class="container-fluid py-4 px-4">
        <h3 class="text-white mb-4"><i class="bi bi-shield-shaded text-warning"></i> Security Audit Logs Registry</h3>

        <div class="glass-panel">
            <div class="table-responsive">
                <table class="table text-white mb-0" style="vertical-align: middle;">
                    <thead>
                        <tr>
                            <th>Log ID</th>
                            <th>Timestamp</th>
                            <th>User Email</th>
                            <th>Action / Security Event</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty logs}">
                                <tr>
                                    <td colspan="4" class="text-center text-muted py-4">No audit logs found in registry.</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="log" items="${logs}">
                                    <tr>
                                        <td>#${log.logId}</td>
                                        <td class="small text-muted">${log.timestamp}</td>
                                        <td class="fw-bold"><c:out value="${log.userEmail}" /></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.action.startsWith('LOGIN_SUCCESS')}">
                                                    <span class="badge bg-success"><i class="bi bi-unlock-fill"></i> <c:out value="${log.action}" /></span>
                                                </c:when>
                                                <c:when test="${log.action.startsWith('LOGIN_FAIL')}">
                                                    <span class="badge bg-danger"><i class="bi bi-lock-fill"></i> <c:out value="${log.action}" /></span>
                                                </c:when>
                                                <c:when test="${log.action.startsWith('PRODUCT_')}">
                                                    <span class="badge bg-info"><i class="bi bi-box-seam"></i> <c:out value="${log.action}" /></span>
                                                </c:when>
                                                <c:when test="${log.action.startsWith('ORDER_STATUS_UPDATE')}">
                                                    <span class="badge bg-warning text-dark"><i class="bi bi-arrow-repeat"></i> <c:out value="${log.action}" /></span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary"><c:out value="${log.action}" /></span>
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

    <!-- Core Scripting Dependencies -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
