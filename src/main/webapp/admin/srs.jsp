<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%!
    private void addFilesRecursively(java.io.File root, java.io.File dir, java.util.List<String> list) {
        java.io.File[] files = dir.listFiles();
        if (files != null) {
            for (java.io.File f : files) {
                String name = f.getName();
                if (f.isDirectory()) {
                    if (!name.equals("target") && !name.equals("tools") && !name.equals(".git") && !name.equals(".gemini") && !name.equals(".idea") && !name.equals(".settings")) {
                        addFilesRecursively(root, f, list);
                    }
                } else {
                    if (name.endsWith(".java") || name.endsWith(".jsp") || name.endsWith(".css") || name.endsWith(".js") || name.endsWith(".sql") || name.equals("pom.xml") || name.equals("run.ps1")) {
                        String relPath = root.toURI().relativize(f.toURI()).getPath();
                        list.add(relPath);
                    }
                }
            }
        }
    }
%>
<%
    // Verify admin privileges
    HttpSession authSession = request.getSession(false);
    com.ecommerce.model.User adminUser = (authSession != null) ? (com.ecommerce.model.User) authSession.getAttribute("user") : null;
    if (adminUser == null || !"ADMIN".equals(adminUser.getRole())) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
        return;
    }

    String projectRootPath = getServletContext().getRealPath("/");
    java.io.File projectDir = new java.io.File(projectRootPath).getParentFile().getParentFile(); // Maven project root
    
    // File selected for viewing
    String fileParam = request.getParameter("file");
    String fileContent = "";
    String fileName = "";
    if (fileParam != null && !fileParam.trim().isEmpty()) {
        java.io.File viewFile = new java.io.File(projectDir, fileParam.trim());
        if (viewFile.getCanonicalPath().startsWith(projectDir.getCanonicalPath())) {
            if (viewFile.exists() && viewFile.isFile()) {
                fileName = viewFile.getName();
                byte[] encoded = java.nio.file.Files.readAllBytes(viewFile.toPath());
                fileContent = new String(encoded, java.nio.charset.StandardCharsets.UTF_8);
            }
        }
    }
    
    // Get list of project source files
    java.util.List<String> fileList = new java.util.ArrayList<>();
    addFilesRecursively(projectDir, projectDir, fileList);
    java.util.Collections.sort(fileList);
    
    request.setAttribute("fileList", fileList);
    request.setAttribute("fileName", fileName);
    request.setAttribute("fileContent", fileContent);
    request.setAttribute("selectedFile", fileParam);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>NexusMarket Admin - Project Source & SRS</title>
    <style>
        .source-container {
            background-color: #FFFDF8;
            border: 1px solid var(--panel-border);
            border-radius: 8px;
            color: #2D2D2D;
            font-family: 'Courier New', Courier, monospace;
            padding: 15px;
            max-height: 600px;
            overflow: auto;
            white-space: pre-wrap;
        }
        .file-link {
            display: block;
            color: var(--text-muted);
            text-decoration: none;
            padding: 6px 12px;
            border-radius: 4px;
            margin-bottom: 2px;
            font-size: 0.85rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .file-link:hover, .file-link.active {
            background-color: rgba(99, 102, 241, 0.15);
            color: var(--text-primary);
        }
    </style>
</head>
<body>
    <%@ include file="../components/admin_navbar.jsp" %>

    <div class="container-fluid py-4 px-4">
        <h3 class="text-white mb-4"><i class="bi bi-file-earmark-code text-warning"></i> Project Source & System Requirements Specification</h3>

        <div class="row">
            <!-- Left Panel: SRS Document -->
            <div class="col-lg-6 mb-4">
                <div class="glass-panel h-100">
                    <h5 class="text-white mb-4"><i class="bi bi-file-text text-indigo"></i> System Requirements Specification (SRS)</h5>
                    <div class="text-light small" style="line-height: 1.8; max-height: 650px; overflow-y: auto; padding-right: 10px;">
                        <h6>1. Scope and Objective</h6>
                        <p class="text-muted"><strong>NexusMarket</strong> is an enterprise-grade aggregated e-commerce platform designed to pool product inventories from major retail partners (Amazon, BestBuy, AliExpress, Walmart, Newegg) into a single storefront. It enables users to browse, filter, sort, and purchase goods, and provides administrators with operational tracking tools.</p>
                        
                        <h6 class="mt-4">2. Core Features Implemented</h6>
                        <ul>
                            <li><strong>Multi-Channel Aggregation:</strong> Product source tagging (e.g., via Amazon) and rating synchronization.</li>
                            <li><strong>Dynamic Catalog Filters:</strong> Filter catalog by category, price threshold (Min/Max), and partner source dynamically via the database layer.</li>
                            <li><strong>Catalog Sorting:</strong> Dynamic sorting by price low-to-high, high-to-low, initial rating, and creation date.</li>
                            <li><strong>Cart & Checkout:</strong> Atomic checkout logic with concurrency-safe stock deduction and payment logs.</li>
                            <li><strong>Security Audit Logs:</strong> Tracking of authentication logs (login success/fails, logouts), product modification events, and customer transaction logs.</li>
                            <li><strong>Data Export:</strong> Administrative reports downloadable in CSV (Excel) and print-friendly web receipt (PDF).</li>
                        </ul>

                        <h6 class="mt-4">3. Architecture & Tech Stack</h6>
                        <p class="text-muted">The system is built on a clean Model-View-Controller (MVC) architecture:</p>
                        <ul>
                            <li><strong>Presentation Layer:</strong> Java Server Pages (JSP), JSTL, Bootstrap 5, Custom Glassmorphic CSS.</li>
                            <li><strong>Control Layer:</strong> HttpServlet Servlets mapped securely, AuthFilter.java session validation, and CsrfFilter.java token validation.</li>
                            <li><strong>Data Access Layer (DAO):</strong> HikariCP Connection Pooling, custom DAO classes (UserDAO, ProductDAO, OrderDAO, AuditLogDAO).</li>
                            <li><strong>Database Stack:</strong> MySQL 8.0 support with a serverless SQLite 3 fallback mode (`ecommerce.db`) for portable local runtimes.</li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Right Panel: Source Browser -->
            <div class="col-lg-6 mb-4">
                <div class="glass-panel h-100">
                    <h5 class="text-white mb-4"><i class="bi bi-folder2-open text-indigo"></i> Project Source Code Explorer</h5>
                    <div class="row">
                        <div class="col-md-4 mb-3" style="border-right: 1px solid var(--panel-border); max-height: 500px; overflow-y: auto;">
                            <c:forEach var="relPath" items="${fileList}">
                                <a href="srs.jsp?file=${relPath}" class="file-link ${selectedFile == relPath ? 'active' : ''}" title="${relPath}">
                                    <i class="bi ${relPath.endsWith('.java') ? 'bi-filetype-java text-indigo' : (relPath.endsWith('.jsp') ? 'bi-filetype-html text-warning' : 'bi-file-earmark')}"></i>
                                    ${relPath}
                                </a>
                            </c:forEach>
                        </div>
                        <div class="col-md-8">
                            <c:choose>
                                <c:when test="${not empty fileContent}">
                                    <h6 class="text-white mb-2"><i class="bi bi-file-code"></i> ${fileName}</h6>
                                    <pre class="source-container"><code><c:out value="${fileContent}" /></code></pre>
                                </c:when>
                                <c:otherwise>
                                    <div class="d-flex flex-column align-items-center justify-content-center text-muted text-center py-5 h-100">
                                        <i class="bi bi-code-square fs-1 mb-2"></i>
                                        <p>Select any source or config file from the explorer sidebar to view its live contents.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
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
