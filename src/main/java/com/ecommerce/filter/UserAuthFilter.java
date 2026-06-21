package com.ecommerce.filter;

import com.ecommerce.model.User;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/dashboard.jsp", "/cart.jsp", "/checkout.jsp", "/orders.jsp", "/order-success.jsp"})
public class UserAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        
        boolean loggedIn = false;
        if (session != null) {
            User user = (User) session.getAttribute("user");
            if (user != null) {
                loggedIn = true;
            }
        }
        
        if (!loggedIn) {
            // Redirect unauthenticated user to login.jsp with error message
            res.sendRedirect(req.getContextPath() + "/login.jsp?error=Authentication+required");
            return;
        }
        
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
