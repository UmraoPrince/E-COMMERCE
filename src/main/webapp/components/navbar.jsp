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

<nav class="navbar navbar-expand-lg navbar-dark sticky-top">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/index.jsp">
            <i class="bi bi-cpu-fill text-indigo me-1"></i> ShopEasy
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        
        <div class="collapse navbar-collapse" id="navbarContent">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/index.jsp"><i class="bi bi-grid-fill me-1"></i> Catalog</a>
                </li>
                <c:if test="${not empty sessionScope.user}">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/orders.jsp"><i class="bi bi-bag-check-fill me-1"></i> My Orders</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/dashboard.jsp"><i class="bi bi-heart-fill me-1"></i> Dashboard</a>
                    </li>
                </c:if>
                <c:if test="${not empty sessionScope.user and sessionScope.user.role == 'ADMIN'}">
                    <li class="nav-item">
                        <a class="nav-link text-warning fw-bold" href="${pageContext.request.contextPath}/admin/dashboard"><i class="bi bi-speedometer2 me-1"></i> Admin Portal</a>
                    </li>
                </c:if>
            </ul>

            <!-- Search bar mapping to catalog -->
            <form class="d-flex me-3" action="${pageContext.request.contextPath}/index.jsp" method="GET">
                <div class="input-group">
                    <input class="form-control" type="search" placeholder="Search products..." name="search" aria-label="Search" value="${param.search}">
                    <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i></button>
                </div>
            </form>

            <ul class="navbar-nav align-items-center">
                <!-- Shopping Cart Icon -->
                <li class="nav-item me-3">
                    <a class="nav-link position-relative" href="${pageContext.request.contextPath}/cart.jsp">
                        <i class="bi bi-cart3 fs-5"></i>
                        <span class="badge rounded-pill badge-cart position-absolute top-0 start-100 translate-middle" style="display:none;">0</span>
                    </a>
                </li>
                
                <!-- Authentication status -->
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle btn btn-primary text-white px-3 py-1" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false" style="border-radius: 8px;">
                                <i class="bi bi-person-circle me-1"></i> <c:out value="${sessionScope.user.name}" />
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end glass-panel border-0 mt-2">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/dashboard.jsp"><i class="bi bi-person me-2"></i> Profile</a></li>
                                <li><hr class="dropdown-divider" style="background-color: var(--panel-border);"></li>
                                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth"><i class="bi bi-box-arrow-right me-2"></i> Logout</a></li>
                            </ul>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item me-2">
                            <a class="nav-link" href="${pageContext.request.contextPath}/login.jsp">Login</a>
                        </li>
                        <li class="nav-item">
                            <a class="btn btn-primary" href="${pageContext.request.contextPath}/register.jsp">Sign Up</a>
                        </li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>

<!-- Bootstrap JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
