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
                String acceptHeader = req.getHeader("Accept");
                String xRequestedWith = req.getHeader("X-Requested-With");
                
                // For API or AJAX requests, return a JSON 403 response
                if ((acceptHeader != null && acceptHeader.contains("application/json")) || 
                    "XMLHttpRequest".equalsIgnoreCase(xRequestedWith)) {
                    res.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    res.setContentType("application/json");
                    res.setCharacterEncoding("UTF-8");
                    res.getWriter().write("{\"status\":\"error\",\"message\":\"Session expired or security token invalid. Please refresh the page.\"}");
                    return;
                }
                
                // For standard form submissions, redirect back to referer or login.jsp with a friendly message
                String referer = req.getHeader("Referer");
                if (referer == null || referer.isEmpty()) {
                    referer = req.getContextPath() + "/login.jsp";
                }
                
                String cleanReferer = cleanUrlQuery(referer);
                String separator = cleanReferer.contains("?") ? "&" : "?";
                String redirectUrl = cleanReferer + separator + "error=Session+expired+or+security+token+invalid.+Please+try+again.";
                
                res.sendRedirect(redirectUrl);
                return;
            }
        }

        chain.doFilter(request, response);
    }

    private String cleanUrlQuery(String url) {
        if (url == null) return "";
        int queryIndex = url.indexOf('?');
        if (queryIndex == -1) {
            return url;
        }
        String baseUrl = url.substring(0, queryIndex);
        String queryString = url.substring(queryIndex + 1);
        StringBuilder cleanQuery = new StringBuilder();
        String[] pairs = queryString.split("&");
        for (String pair : pairs) {
            if (!pair.startsWith("error=")) {
                if (cleanQuery.length() > 0) {
                    cleanQuery.append("&");
                }
                cleanQuery.append(pair);
            }
        }
        if (cleanQuery.length() > 0) {
            return baseUrl + "?" + cleanQuery.toString();
        } else {
            return baseUrl;
        }
    }

    @Override
    public void destroy() {}
}
