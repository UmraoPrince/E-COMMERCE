package com.ecommerce.filter;

import com.ecommerce.model.User;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/admin/*")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        
        boolean loggedIn = false;
        boolean isAdmin = false;
        
        if (session != null) {
            User user = (User) session.getAttribute("user");
            if (user != null) {
                loggedIn = true;
                if ("ADMIN".equals(user.getRole())) {
                    isAdmin = true;
                }
            }
        }
        
        if (!loggedIn || !isAdmin) {
            // Secure redirection to login page
            res.sendRedirect(req.getContextPath() + "/login.jsp?error=Admin+Access+Required");
            return;
        }
        
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
