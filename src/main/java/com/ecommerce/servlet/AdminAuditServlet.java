package com.ecommerce.servlet;

import com.ecommerce.dao.AuditLogDAO;
import com.ecommerce.model.AuditLog;
import com.ecommerce.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/audit")
public class AdminAuditServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Administrators only.");
            return;
        }

        List<AuditLog> logs = auditLogDAO.getAllLogs();
        request.setAttribute("logs", logs);
        request.getRequestDispatcher("/admin/audit.jsp").forward(request, response);
    }
}
