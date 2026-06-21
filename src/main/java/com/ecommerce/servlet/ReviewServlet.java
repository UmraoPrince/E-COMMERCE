package com.ecommerce.servlet;

import com.ecommerce.dao.ReviewDAO;
import com.ecommerce.model.Review;
import com.ecommerce.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/review")
public class ReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String prodIdStr = request.getParameter("productId");
        String ratingStr = request.getParameter("rating");
        String reviewText = request.getParameter("reviewText");

        if (prodIdStr == null || ratingStr == null || reviewText == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters for review.");
            return;
        }

        try {
            int productId = Integer.parseInt(prodIdStr);
            int rating = Integer.parseInt(ratingStr);

            if (rating < 1 || rating > 5) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Rating must be between 1 and 5.");
                return;
            }

            Review review = new Review();
            review.setUserId(user.getUserId());
            review.setProductId(productId);
            review.setRating(rating);
            review.setReviewText(reviewText.trim());

            reviewDAO.addReview(review);

            // Redirect back to product details page
            response.sendRedirect(request.getContextPath() + "/product-details.jsp?id=" + productId);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid format for numeric inputs.");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Redirect GET request to home catalog
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }
}
