// Client-side Cart & E-commerce Operations

// Dynamically sync navbar cart count badge on page load
$(document).ready(function() {
    updateCartCount();
});

/**
 * Add product to cart via AJAX POST
 */
function addToCart(productId) {
    var csrfToken = window.csrfToken || '';
    
    $.ajax({
        url: 'cart',
        type: 'POST',
        data: { 
            action: 'add', 
            productId: productId,
            csrfToken: csrfToken
        },
        dataType: 'json',
        success: function(response) {
            if (response.status === 'success') {
                showToast('Success', 'Product added to cart!', 'success');
                // Sync badge
                if (response.cartCount !== undefined) {
                    $('.badge-cart').text(response.cartCount).show();
                }
            } else if (response.status === 'login') {
                showToast('Action Required', 'Please login to add items to your cart.', 'warning');
                setTimeout(function() {
                    window.location.href = 'login.jsp';
                }, 2000);
            } else {
                showToast('Error', response.message || 'Failed to add product.', 'danger');
            }
        },
        error: function(xhr, status, error) {
            console.error('Cart error:', error);
            showToast('Error', 'Unable to complete cart request. Please try again.', 'danger');
        }
    });
}

/**
 * Update cart item quantity via AJAX POST
 */
function updateCartQty(productId, quantity) {
    var csrfToken = window.csrfToken || '';
    
    $.ajax({
        url: 'cart',
        type: 'POST',
        data: {
            action: 'update',
            productId: productId,
            quantity: quantity,
            csrfToken: csrfToken
        },
        dataType: 'json',
        success: function(response) {
            if (response.status === 'success') {
                // Reload cart page to update prices and subtotals dynamically
                window.location.reload();
            } else {
                showToast('Error', response.message || 'Failed to update quantity.', 'danger');
            }
        },
        error: function() {
            showToast('Error', 'Unable to update cart quantity.', 'danger');
        }
    });
}

/**
 * Remove product from cart via AJAX POST
 */
function removeFromCart(productId) {
    var csrfToken = window.csrfToken || '';
    
    $.ajax({
        url: 'cart',
        type: 'POST',
        data: {
            action: 'remove',
            productId: productId,
            csrfToken: csrfToken
        },
        dataType: 'json',
        success: function(response) {
            if (response.status === 'success') {
                window.location.reload();
            } else {
                showToast('Error', 'Failed to remove item.', 'danger');
            }
        },
        error: function() {
            showToast('Error', 'Unable to remove item from cart.', 'danger');
        }
    });
}

/**
 * Fetch and sync cart item count badge from servlet GET endpoint
 */
function updateCartCount() {
    $.ajax({
        url: 'cart',
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            var count = response.cartCount || 0;
            if (count > 0) {
                $('.badge-cart').text(count).show();
            } else {
                $('.badge-cart').hide();
            }
        }
    });
}

/**
 * Helper to display temporary visual status notification banners
 */
function showToast(title, message, type) {
    // Check if toast container exists, create if not
    var container = $('#toast-container');
    if (container.length === 0) {
        $('body').append('<div id="toast-container" style="position: fixed; bottom: 20px; right: 20px; z-index: 9999; width: 320px;"></div>');
        container = $('#toast-container');
    }

    var alertClass = 'bg-primary';
    if (type === 'success') alertClass = 'bg-success';
    if (type === 'warning') alertClass = 'bg-warning text-dark';
    if (type === 'danger') alertClass = 'bg-danger';

    var toastHtml = `
        <div class="toast show align-items-center text-white ${alertClass} border-0 mb-2" role="alert" aria-live="assertive" aria-atomic="true" style="backdrop-filter: blur(10px); background-opacity: 0.95; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">
            <div class="d-flex">
                <div class="toast-body">
                    <strong>${title}:</strong> ${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close" onclick="$(this).closest('.toast').remove()"></button>
            </div>
        </div>
    `;
    
    var $toast = $(toastHtml);
    container.append($toast);
    
    // Auto remove after 3.5 seconds
    setTimeout(function() {
        $toast.fadeOut(400, function() {
            $(this).remove();
        });
    }, 3500);
}
