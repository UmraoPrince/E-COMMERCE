<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy - Login</title>
</head>
<body>
    <%@ include file="components/navbar.jsp" %>

    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div class="glass-panel">
                    <h3 class="text-center text-white mb-4"><i class="bi bi-shield-lock text-indigo"></i> Sign In</h3>
                    
                    <!-- Successful Signup Alert -->
                    <c:if test="${param.success == 1}">
                        <div class="custom-alert text-center">
                            <i class="bi bi-check-circle-fill me-1"></i> Registration successful! Please login below.
                        </div>
                    </c:if>
                    
                    <!-- Successful Logout Alert -->
                    <c:if test="${param.logout == 1}">
                        <div class="custom-alert text-center" style="color: var(--accent-color); border-color: rgba(99,102,241,0.2); background: rgba(99,102,241,0.05);">
                            <i class="bi bi-info-circle-fill me-1"></i> Logged out successfully.
                        </div>
                    </c:if>

                    <!-- Error Alert -->
                    <c:if test="${not empty error}">
                        <div class="custom-alert-error text-center">
                            <i class="bi bi-exclamation-triangle-fill me-1"></i> <c:out value="${error}" />
                        </div>
                    </c:if>
                    <c:if test="${not empty param.error}">
                        <div class="custom-alert-error text-center">
                            <i class="bi bi-exclamation-triangle-fill me-1"></i> <c:out value="${param.error}" />
                        </div>
                    </c:if>

                    <form action="auth" method="POST" class="mt-3">
                        <input type="hidden" name="action" value="login">
                        
                        <!-- CSRF Token -->
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

                        <div class="mb-3">
                            <label class="form-label text-muted">Email Address</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                                <input type="email" name="email" class="form-control" placeholder="name@example.com" required value="${param.email}">
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label text-muted">Password</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-key"></i></span>
                                <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-2.5 mb-3">Login to Account</button>
                    </form>

                    <div class="text-center mt-4 text-muted small">
                        Don't have an account? <a href="register.jsp" class="text-indigo text-decoration-none fw-bold">Sign Up</a>
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
