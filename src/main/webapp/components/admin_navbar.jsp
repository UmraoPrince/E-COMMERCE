<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Global HTML Header Dependencies -->
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<!-- Bootstrap 5 CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- Bootstrap Icons -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
<!-- Custom Glassmorphic Stylesheet -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=1.0.1">

<!-- Bind CSRF Token for JavaScript AJAX requests -->
<script>
    window.csrfToken = "${sessionScope.csrfToken}";
</script>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top border-bottom border-warning">
    <div class="container-fluid">
        <a class="navbar-brand text-warning" href="${pageContext.request.contextPath}/admin/dashboard">
            <i class="bi bi-shield-lock-fill me-1"></i> ShopEasy Admin
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#adminNavbarContent" aria-controls="adminNavbarContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        
        <div class="collapse navbar-collapse" id="adminNavbarContent">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard"><i class="bi bi-speedometer2 me-1"></i> Dashboard</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/products"><i class="bi bi-box-seam me-1"></i> Products</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/orders"><i class="bi bi-receipt me-1"></i> Orders</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/users"><i class="bi bi-people me-1"></i> Users</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/audit"><i class="bi bi-shield-shaded me-1"></i> Audit Logs</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/srs.jsp"><i class="bi bi-file-earmark-code me-1"></i> Project Source & SRS</a>
                </li>
            </ul>

            <ul class="navbar-nav align-items-center">
                <li class="nav-item me-3">
                    <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/index.jsp">
                        <i class="bi bi-shop me-1"></i> View Live Store
                    </a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle btn btn-warning text-dark fw-bold px-3 py-1" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false" style="border-radius: 8px;">
                        <i class="bi bi-person-lock me-1"></i> <c:out value="${sessionScope.user.name}" />
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end glass-panel border-0 mt-2">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/dashboard.jsp"><i class="bi bi-person me-2"></i> Profile</a></li>
                        <li><hr class="dropdown-divider" style="background-color: var(--panel-border);"></li>
                        <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth"><i class="bi bi-box-arrow-right me-2"></i> Logout</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- Bootstrap JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
