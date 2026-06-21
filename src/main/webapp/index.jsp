<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.ecommerce.dao.ProductDAO" %>
<%@ page import="com.ecommerce.dao.CategoryDAO" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.model.Category" %>
<%@ page import="java.util.List" %>
<%
    // Safely load catalog variables directly if loaded without servlet forwarding
    List<Product> productsList = (List<Product>) request.getAttribute("products");
    List<Category> categoriesList = (List<Category>) request.getAttribute("categories");
    
    ProductDAO pDAO = new ProductDAO();
    CategoryDAO cDAO = new CategoryDAO();
    
    if (categoriesList == null) {
        categoriesList = cDAO.getAllCategories();
        request.setAttribute("categories", categoriesList);
    }
    
    if (productsList == null) {
        String search = request.getParameter("search");
        String catIdStr = request.getParameter("category");
        String pageStr = request.getParameter("page");
        String minPriceStr = request.getParameter("minPrice");
        String maxPriceStr = request.getParameter("maxPrice");
        String[] sources = request.getParameterValues("sources");
        String sortBy = request.getParameter("sortBy");
        
        Integer categoryId = (catIdStr != null && !catIdStr.trim().isEmpty()) ? Integer.parseInt(catIdStr) : null;
        int currentPage = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;
        int limit = 6; 
        
        Double minPrice = (minPriceStr != null && !minPriceStr.trim().isEmpty()) ? Double.parseDouble(minPriceStr.trim()) : null;
        Double maxPrice = (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) ? Double.parseDouble(maxPriceStr.trim()) : null;
        
        java.util.List<String> sourcesList = null;
        if (sources != null && sources.length > 0) {
            sourcesList = java.util.Arrays.asList(sources);
        }
        
        productsList = pDAO.getAllProducts(currentPage, limit, search, categoryId, minPrice, maxPrice, sourcesList, sortBy);
        request.setAttribute("products", productsList);
        
        int totalProducts = pDAO.getTotalProductsCount(search, categoryId, minPrice, maxPrice, sourcesList);
        int totalPages = (int) Math.ceil((double) totalProducts / limit);
        if (totalPages == 0) totalPages = 1;
        
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy - Modern E-Commerce Catalog</title>
</head>
<body>
    <!-- Navigation Header -->
    <%@ include file="components/navbar.jsp" %>

    <!-- Hero Banner Section -->
    <div class="container mt-4">
        <div class="glass-panel text-center py-5 mb-5" style="background: linear-gradient(135deg, rgba(255,255,255,0.85), rgba(255,248,231,0.75)); border: 1px solid rgba(255,255,255,0.8); box-shadow: 0 10px 40px rgba(0,0,0,0.08);">
            <h1 class="display-4 fw-extrabold" style="color: #2D2D2D;">Experience Seamless Shopping</h1>
            <p class="lead" style="color: #666666;">Premium gadgets, elegant fashion, and high-performance appliances at your fingertips.</p>
            <a href="#shop-now" class="btn btn-lg px-4 mt-2" style="background: linear-gradient(135deg, #D4A373, #E9C46A); color: #ffffff; border: none; font-weight: 600; box-shadow: 0 4px 15px rgba(212, 163, 115, 0.3);">Shop Catalog</a>
        </div>
    </div>

    <!-- Main Store Section -->
    <div class="container" id="shop-now">
        <div class="row">
            <!-- Left Side Categories & Advanced Filters -->
            <div class="col-lg-3 mb-4">
                <form action="index.jsp" method="GET" class="d-flex flex-column gap-3">
                    <c:if test="${not empty param.search}">
                        <input type="hidden" name="search" value="${param.search}">
                    </c:if>
                    <c:if test="${not empty param.sortBy}">
                        <input type="hidden" name="sortBy" value="${param.sortBy}">
                    </c:if>

                    <!-- Category Filter -->
                    <div class="glass-panel">
                        <h5 class="text-white mb-3"><i class="bi bi-grid-3x3-gap-fill text-indigo me-1"></i> Category</h5>
                        <select name="category" class="form-select border-0" onchange="this.form.submit()">
                            <option value="" ${empty param.category ? 'selected' : ''}>All Categories</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.categoryId}" ${param.category == cat.categoryId ? 'selected' : ''}>
                                    <c:out value="${cat.categoryName}" />
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Price Filter -->
                    <div class="glass-panel">
                        <h5 class="text-white mb-3"><i class="bi bi-currency-rupee text-indigo me-1"></i> Price Range</h5>
                        <div class="d-flex gap-2">
                            <input type="number" name="minPrice" class="form-control form-control-sm" placeholder="Min" value="${param.minPrice}">
                            <input type="number" name="maxPrice" class="form-control form-control-sm" placeholder="Max" value="${param.maxPrice}">
                        </div>
                    </div>

                    <!-- Source Filter -->
                    <div class="glass-panel">
                        <h5 class="text-white mb-3"><i class="bi bi-funnel-fill text-indigo me-1"></i> Partner Source</h5>
                        <div class="d-flex flex-column gap-2">
                            <c:forEach var="srcOption" items="${['Amazon', 'AliExpress', 'Walmart', 'BestBuy', 'Newegg', 'Local']}">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="sources" value="${srcOption}" id="src_${srcOption}"
                                           <c:forEach var="selectedSrc" items="${paramValues.sources}">
                                               <c:if test="${selectedSrc == srcOption}">checked</c:if>
                                           </c:forEach>
                                    >
                                    <label class="form-check-label small" for="src_${srcOption}">
                                        ${srcOption}
                                    </label>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100"><i class="bi bi-filter"></i> Apply Filters</button>
                    <a href="index.jsp" class="btn btn-outline-light btn-sm w-100"><i class="bi bi-x-circle"></i> Clear All</a>
                </form>
            </div>

            <!-- Right Catalog Grid -->
            <div class="col-lg-9">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h3 class="text-white mb-0">
                        <c:choose>
                            <c:when test="${not empty param.search}">
                                Search Results for "<c:out value="${param.search}" />"
                            </c:when>
                            <c:otherwise>
                                Discover Products
                            </c:otherwise>
                        </c:choose>
                    </h3>
                    
                    <!-- Sorting Dropdown -->
                    <form action="index.jsp" method="GET" class="d-inline-flex gap-2 align-items-center">
                        <c:if test="${not empty param.category}"><input type="hidden" name="category" value="${param.category}"></c:if>
                        <c:if test="${not empty param.search}"><input type="hidden" name="search" value="${param.search}"></c:if>
                        <c:if test="${not empty param.minPrice}"><input type="hidden" name="minPrice" value="${param.minPrice}"></c:if>
                        <c:if test="${not empty param.maxPrice}"><input type="hidden" name="maxPrice" value="${param.maxPrice}"></c:if>
                        <c:forEach var="src" items="${paramValues.sources}">
                            <input type="hidden" name="sources" value="${src}">
                        </c:forEach>
                        
                        <span class="text-muted small text-nowrap d-none d-sm-inline">Sort By:</span>
                        <select name="sortBy" class="form-select form-select-sm border-0 text-white" onchange="this.form.submit();" style="width: auto; background-color: rgba(255,255,255,0.08); border-radius: 8px;">
                            <option value="featured" ${param.sortBy == 'featured' ? 'selected' : ''}>Featured</option>
                            <option value="price-low" ${param.sortBy == 'price-low' ? 'selected' : ''}>Price: Low to High</option>
                            <option value="price-high" ${param.sortBy == 'price-high' ? 'selected' : ''}>Price: High to Low</option>
                            <option value="rating" ${param.sortBy == 'rating' ? 'selected' : ''}>Top Rated</option>
                        </select>
                    </form>
                </div>

                <!-- Products Grid -->
                <c:choose>
                    <c:when test="${empty products}">
                        <div class="glass-panel text-center py-5">
                            <i class="bi bi-search fs-1 text-muted mb-3 d-block"></i>
                            <h4 class="text-white">No products found</h4>
                            <p class="text-muted">Try refining your search keyword or selecting a different category.</p>
                            <a href="index.jsp" class="btn btn-primary mt-2">Reset Filters</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="row">
                            <c:forEach var="product" items="${products}">
                                <div class="col-md-6 col-xl-4 mb-4">
                                    <div class="card h-100">
                                        <!-- Image Container with placeholder fallback -->
                                         <div style="background: rgba(255, 255, 255, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.05); overflow:hidden; position: relative;">
                                            <c:choose>
                                                <c:when test="${not empty product.image}">
                                                    <img src="${pageContext.request.contextPath}/${product.image}" class="card-img-top" alt="<c:out value='${product.productName}' />">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="d-flex align-items-center justify-content-center text-muted" style="height: 220px; background: rgba(255,255,255,0.2);">
                                                        <i class="bi bi-image fs-1"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            
                                            <!-- Stock status badge -->
                                            <c:choose>
                                                <c:when test="${product.stock > 0}">
                                                    <span class="badge bg-success position-absolute top-0 end-0 m-3">In Stock</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-danger position-absolute top-0 end-0 m-3">Out of Stock</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <div class="card-body d-flex flex-column justify-content-between">
                                            <div>
                                                <div class="d-flex justify-content-between align-items-center mb-1">
                                                    <span class="text-indigo text-uppercase font-size-sm fw-bold" style="font-size: 0.75rem;"><c:out value="${product.categoryName}" /></span>
                                                    <span class="badge bg-dark text-light border border-secondary" style="font-size: 0.7rem; padding: 2px 6px; border-radius: 4px;">via <c:out value="${product.source}" /></span>
                                                </div>
                                                <h5 class="card-title text-truncate mt-1" title="<c:out value='${product.productName}' />"><c:out value="${product.productName}" /></h5>
                                                <div class="text-warning mb-2" style="font-size: 0.85rem;">
                                                    <c:forEach begin="1" end="5" var="star">
                                                        <c:choose>
                                                            <c:when test="${star <= product.rating}">★</c:when>
                                                            <c:otherwise>☆</c:otherwise>
                                                        </c:choose>
                                                    </c:forEach>
                                                    <span class="text-muted small ms-1">${product.rating}</span>
                                                </div>
                                                <p class="card-text text-truncate-2" style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; height: 40px;"><c:out value="${product.description}" /></p>
                                            </div>
                                            <div class="mt-3">
                                                <div class="d-flex justify-content-between align-items-center mb-3">
                                                    <h5 class="text-success mb-0">₹<c:out value="${product.price}" /></h5>
                                                    <span class="text-muted small">${product.stock} units left</span>
                                                </div>
                                                <div class="row g-2">
                                                    <div class="col-4">
                                                        <a href="product-details.jsp?id=${product.productId}" class="btn btn-outline-light w-100 btn-sm" title="View Details"><i class="bi bi-eye"></i> Details</a>
                                                    </div>
                                                    <div class="col-4">
                                                        <button class="btn btn-primary w-100 btn-sm" onclick="addToCart(${product.productId})" ${product.stock <= 0 ? 'disabled' : ''} title="Add to Cart">
                                                            <i class="bi bi-cart-plus"></i> Add
                                                        </button>
                                                    </div>
                                                    <div class="col-4">
                                                        <a href="dashboard.jsp?action=add&productId=${product.productId}&csrfToken=${sessionScope.csrfToken}" class="btn btn-outline-danger w-100 btn-sm" title="Save to Wishlist">
                                                            <i class="bi bi-heart-fill"></i> Save
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <!-- Dynamic Pagination Controls -->
                        <c:if test="${totalPages > 1}">
                            <nav class="d-flex justify-content-center mt-4">
                                <ul class="pagination">
                                    <c:set var="filterParams">
                                        <c:if test="${not empty param.category}">&category=${param.category}</c:if>
                                        <c:if test="${not empty param.search}">&search=${param.search}</c:if>
                                        <c:if test="${not empty param.minPrice}">&minPrice=${param.minPrice}</c:if>
                                        <c:if test="${not empty param.maxPrice}">&maxPrice=${param.maxPrice}</c:if>
                                        <c:if test="${not empty param.sortBy}">&sortBy=${param.sortBy}</c:if>
                                        <c:forEach var="src" items="${paramValues.sources}">&sources=${src}</c:forEach>
                                    </c:set>
                                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                        <a class="page-link glass-panel py-2 px-3 border-0 me-2" 
                                           href="index.jsp?page=${currentPage - 1}${filterParams}" 
                                           style="background: rgba(255,255,255,0.05); color: var(--text-primary); border-radius: 8px;">
                                            Previous
                                        </a>
                                    </li>
                                    <c:forEach var="i" begin="1" end="${totalPages}">
                                        <li class="page-item">
                                            <a class="page-link glass-panel py-2 px-3 border-0 me-2" 
                                               href="index.jsp?page=${i}${filterParams}" 
                                               style="background: ${currentPage == i ? 'var(--accent-gradient)' : 'rgba(255,255,255,0.05)'}; color: var(--text-primary); border-radius: 8px;">
                                                ${i}
                                            </a>
                                        </li>
                                    </c:forEach>
                                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                        <a class="page-link glass-panel py-2 px-3 border-0" 
                                           href="index.jsp?page=${currentPage + 1}${filterParams}" 
                                           style="background: rgba(255,255,255,0.05); color: var(--text-primary); border-radius: 8px;">
                                            Next
                                        </a>
                                    </li>
                                </ul>
                            </nav>
                        </c:if>
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
