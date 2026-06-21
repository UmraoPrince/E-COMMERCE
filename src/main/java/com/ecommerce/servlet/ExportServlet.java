package com.ecommerce.servlet;

import com.ecommerce.dao.OrderDAO;
import com.ecommerce.model.Order;
import com.ecommerce.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/admin/export")
public class ExportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Administrators only.");
            return;
        }

        String format = request.getParameter("format");
        List<Order> orders = orderDAO.getAllOrders();

        if ("XLS".equalsIgnoreCase(format)) {
            response.setContentType("text/csv; charset=UTF-8");
            response.setHeader("Content-Disposition", "attachment; filename=orders_report.csv");
            
            try (PrintWriter out = response.getWriter()) {
                // BOM for Excel UTF-8 compatibility
                out.write('\ufeff');
                out.println("Order ID,Customer,Date,Total Amount,Payment Method,Payment Status,Order Status");
                for (Order o : orders) {
                    out.printf("\"#%d\",\"%s\",\"%s\",\"$%.2f\",\"%s\",\"%s\",\"%s\"\n",
                            o.getOrderId(),
                            escapeCsv(o.getUserName()),
                            o.getOrderDate() != null ? o.getOrderDate().toString() : "",
                            o.getTotalAmount(),
                            o.getPaymentMethod(),
                            o.getPaymentStatus(),
                            o.getStatus()
                    );
                }
            }
        } else if ("PDF".equalsIgnoreCase(format)) {
            response.setContentType("text/html; charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.println("<!DOCTYPE html>");
                out.println("<html>");
                out.println("<head>");
                out.println("  <title>NexusMarket - Sales & Orders Report</title>");
                out.println("  <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css' rel='stylesheet'>");
                out.println("  <style>");
                out.println("    body { font-family: 'Segoe UI', system-ui, sans-serif; padding: 30px; background: white; color: black; }");
                out.println("    .report-header { border-bottom: 2px solid #0f172a; padding-bottom: 15px; margin-bottom: 30px; }");
                out.println("    @media print { .no-print { display: none; } }");
                out.println("  </style>");
                out.println("</head>");
                out.println("<body>");
                out.println("  <div class='container'>");
                out.println("    <div class='no-print text-end mb-4'>");
                out.println("      <button class='btn btn-primary' onclick='window.print()'>Print / Save as PDF</button>");
                out.println("      <button class='btn btn-secondary' onclick='window.close()'>Close</button>");
                out.println("    </div>");
                out.println("    <div class='report-header d-flex justify-content-between align-items-center'>");
                out.println("      <div>");
                out.println("        <h2>NexusMarket Enterprise</h2>");
                out.println("        <p class='text-muted mb-0'>Sales Operations & Orders Report</p>");
                out.println("      </div>");
                out.println("      <div class='text-end'>");
                out.println("        <p class='mb-0'><strong>Generated On:</strong> " + new java.util.Date() + "</p>");
                out.println("        <p class='mb-0'><strong>Total Orders:</strong> " + orders.size() + "</p>");
                out.println("      </div>");
                out.println("    </div>");
                out.println("    <table class='table table-bordered table-striped'>");
                out.println("      <thead class='table-dark'>");
                out.println("        <tr>");
                out.println("          <th>Order ID</th>");
                out.println("          <th>Customer</th>");
                out.println("          <th>Order Date</th>");
                out.println("          <th>Amount</th>");
                out.println("          <th>Payment</th>");
                out.println("          <th>Status</th>");
                out.println("        </tr>");
                out.println("      </thead>");
                out.println("      <tbody>");
                
                double grandTotal = 0;
                for (Order o : orders) {
                    double amt = o.getTotalAmount() != null ? o.getTotalAmount().doubleValue() : 0.0;
                    if (!"CANCELLED".equalsIgnoreCase(o.getStatus())) {
                        grandTotal += amt;
                    }
                    out.println("        <tr>");
                    out.println("          <td>#" + o.getOrderId() + "</td>");
                    out.println("          <td>" + (o.getUserName() != null ? o.getUserName() : "N/A") + "</td>");
                    out.println("          <td>" + (o.getOrderDate() != null ? o.getOrderDate().toString() : "") + "</td>");
                    out.println("          <td class='text-end'>$" + String.format("%.2f", amt) + "</td>");
                    out.println("          <td>" + o.getPaymentMethod() + " (" + o.getPaymentStatus() + ")</td>");
                    out.println("          <td>" + o.getStatus() + "</td>");
                    out.println("          </tr>");
                }
                
                out.println("        <tr class='table-info fw-bold'>");
                out.println("          <td colspan='3' class='text-end'>Active Revenue (Excludes Cancelled)</td>");
                out.println("          <td class='text-end'>$" + String.format("%.2f", grandTotal) + "</td>");
                out.println("          <td colspan='2'></td>");
                out.println("        </tr>");
                out.println("      </tbody>");
                out.println("    </table>");
                out.println("  </div>");
                out.println("</body>");
                out.println("</html>");
            }
        }
    }

    private String escapeCsv(String value) {
        if (value == null) return "";
        return value.replace("\"", "\"\"");
    }
}
