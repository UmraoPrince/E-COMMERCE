package com.ecommerce.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.UUID;

@WebFilter("/*")
public class CsrfFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(true);

        // 1. Generate CSRF token if it doesn't exist
        String csrfToken = (String) session.getAttribute("csrfToken");
        if (csrfToken == null) {
            csrfToken = UUID.randomUUID().toString();
            session.setAttribute("csrfToken", csrfToken);
        }

        String method = req.getMethod();

        // 2. Only validate state-changing POST requests
        if ("POST".equalsIgnoreCase(method)) {
            String contentType = req.getContentType();
            
            // Exclude multipart forms (they will be validated in the servlet because parameters require parsing)
            if (contentType != null && contentType.toLowerCase().startsWith("multipart/form-data")) {
                chain.doFilter(request, response);
                return;
            }

            // Retrieve token from parameter or header
            String requestToken = req.getParameter("csrfToken");
            if (requestToken == null || requestToken.isEmpty()) {
                requestToken = req.getHeader("X-CSRF-Token");
            }

            if (requestToken == null || !requestToken.equals(csrfToken)) {
                // Deny request
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid or missing CSRF token. Request denied for safety.");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
