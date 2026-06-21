<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>ShopEasy - Register</title>
</head>
<body>
    <%@ include file="components/navbar.jsp" %>

    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-7 col-lg-6">
                <div class="glass-panel">
                    <!-- Alert Container -->
                    <div id="alert-container">
                        <c:if test="${not empty error}">
                            <div class="custom-alert-error text-center">
                                <i class="bi bi-exclamation-triangle-fill me-1"></i> <c:out value="${error}" />
                            </div>
                        </c:if>
                    </div>

                    <!-- STEP 1: Registration Form -->
                    <form id="registerForm" class="mt-3" <c:if test="${not empty sessionScope.tempUser}">style="display: none;"</c:if>>
                        <h3 class="text-center text-white mb-4"><i class="bi bi-person-plus text-indigo"></i> Create Account</h3>
                        <p class="text-center text-muted small mb-4">Fill in your details to receive an email verification OTP code.</p>
                        
                        <!-- CSRF Token -->
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted">Full Name *</label>
                                <input type="text" name="name" class="form-control" placeholder="John Doe" required value="${param.name}">
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted">Email Address *</label>
                                <input type="email" name="email" class="form-control" placeholder="john@example.com" required value="${param.email}">
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted">Password *</label>
                                <input type="password" name="password" class="form-control" placeholder="Minimum 6 characters" required minlength="6">
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted">Mobile Number</label>
                                <input type="tel" name="mobile" class="form-control" placeholder="9999999999" value="${param.mobile}">
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label text-muted">Shipping Address</label>
                            <textarea name="address" class="form-control" rows="3" placeholder="Enter default delivery address..."><c:out value="${param.address}" /></textarea>
                        </div>

                        <button type="submit" id="btnSendOtp" class="btn btn-primary w-100 py-2.5 mb-3">
                            <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true" style="display: none;"></span>
                            Send Verification OTP
                        </button>
                    </form>

                    <!-- STEP 2: OTP Verification Form (hidden by default) -->
                    <form id="verifyForm" class="mt-3" <c:choose><c:when test="${not empty sessionScope.tempUser}">style="display: block;"</c:when><c:otherwise>style="display: none;"</c:otherwise></c:choose>>
                        <div class="text-center mb-4">
                            <div class="verify-icon-wrapper mb-3">
                                <div class="verify-badge">
                                    <i class="bi bi-shield-check text-indigo" style="font-size: 3rem;"></i>
                                </div>
                            </div>
                            <h4 class="text-white">Verify Your Email</h4>
                            <p class="text-muted small">We've sent a 6-digit verification code to <strong id="displayEmail" class="text-indigo"><c:out value="${not empty sessionScope.tempUser ? sessionScope.tempUser.email : 'user@example.com'}" /></strong>. Please check your email.</p>
                        </div>

                        <!-- OTP Inputs -->
                        <div class="mb-4 text-center">
                            <label class="form-label text-muted mb-3">Enter 6-Digit OTP</label>
                            <div class="otp-inputs-container d-flex justify-content-center gap-2 mb-2">
                                <input type="text" class="otp-digit form-control text-center text-white font-monospace fs-4" maxlength="1" required autocomplete="off" style="width: 45px; height: 50px;">
                                <input type="text" class="otp-digit form-control text-center text-white font-monospace fs-4" maxlength="1" required autocomplete="off" style="width: 45px; height: 50px;">
                                <input type="text" class="otp-digit form-control text-center text-white font-monospace fs-4" maxlength="1" required autocomplete="off" style="width: 45px; height: 50px;">
                                <input type="text" class="otp-digit form-control text-center text-white font-monospace fs-4" maxlength="1" required autocomplete="off" style="width: 45px; height: 50px;">
                                <input type="text" class="otp-digit form-control text-center text-white font-monospace fs-4" maxlength="1" required autocomplete="off" style="width: 45px; height: 50px;">
                                <input type="text" class="otp-digit form-control text-center text-white font-monospace fs-4" maxlength="1" required autocomplete="off" style="width: 45px; height: 50px;">
                            </div>
                            <!-- Hidden input holding full concatenated OTP code -->
                            <input type="hidden" name="otp" id="fullOtp">
                        </div>

                        <button type="submit" id="btnVerify" class="btn btn-primary w-100 py-2.5 mb-3">
                            <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true" style="display: none;"></span>
                            Verify Code & Register
                        </button>

                        <div class="text-center mt-3 text-muted small">
                            Didn't receive the email? 
                            <a href="#" id="btnResend" class="text-indigo text-decoration-none fw-bold disabled">
                                Resend Code <span id="timerText">(59s)</span>
                            </a>
                        </div>
                    </form>

                    <!-- STEP 3: Success State (hidden by default) -->
                    <div id="successState" class="text-center py-4" style="display: none;">
                        <div class="success-checkmark mb-4">
                            <div class="check-icon">
                                <span class="icon-line line-tip"></span>
                                <span class="icon-line line-long"></span>
                                <div class="icon-circle"></div>
                                <div class="icon-fix"></div>
                            </div>
                        </div>
                        <h4 class="text-white mb-2">Email Verified!</h4>
                        <p class="text-muted">Your account was successfully registered.<br>Logging you in and redirecting...</p>
                    </div>

                    <div id="signinLink" class="text-center mt-4 text-muted small">
                        Already have an account? <a href="login.jsp" class="text-indigo text-decoration-none fw-bold">Sign In</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Core Scripting Dependencies -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>

    <script>
        $(document).ready(function() {
            var timer;
            var countdown = 59;
            var userEmail = '';

            <c:if test="${not empty sessionScope.tempUser}">
            userEmail = '<c:out value="${sessionScope.tempUser.email}" />';
            startTimer();
            setTimeout(function() {
                $('.otp-digit').first().focus();
            }, 100);
            </c:if>

            // Focus first input box on load
            if (!$('#verifyForm').is(':visible')) {
                $('input[name="name"]').focus();
            }

            // Handle digit auto-focusing for OTP inputs
            $('.otp-digit').on('keyup input', function(e) {
                var $this = $(this);
                var val = $this.val();
                
                // Allow only digits
                if (!/^\d*$/.test(val)) {
                    $this.val('');
                    return;
                }

                // Auto-advance to next input field
                if (val.length === 1) {
                    $this.next('.otp-digit').focus();
                }

                assembleOtp();
            });

            // Handle backspace key inside OTP input boxes
            $('.otp-digit').on('keydown', function(e) {
                var $this = $(this);
                if (e.key === 'Backspace') {
                    if ($this.val() === '') {
                        $this.prev('.otp-digit').focus().val('');
                    } else {
                        $this.val('');
                    }
                    assembleOtp();
                }
            });

            // Handle pasting standard 6-digit code
            $('.otp-digit').first().on('paste', function(e) {
                var clipboardData = e.originalEvent.clipboardData || window.clipboardData;
                var pastedData = clipboardData.getData('text');
                
                if (/^\d{6}$/.test(pastedData)) {
                    $('.otp-digit').each(function(index) {
                        $(this).val(pastedData[index]);
                    });
                    assembleOtp();
                    $('#btnVerify').focus();
                    e.preventDefault();
                }
            });

            function assembleOtp() {
                var otp = '';
                $('.otp-digit').each(function() {
                    otp += $(this).val();
                });
                $('#fullOtp').val(otp);
            }

            function startTimer() {
                clearInterval(timer);
                countdown = 59;
                $('#timerText').text('(' + countdown + 's)');
                $('#btnResend').addClass('disabled');
                
                timer = setInterval(function() {
                    countdown--;
                    if (countdown <= 0) {
                        clearInterval(timer);
                        $('#timerText').text('');
                        $('#btnResend').removeClass('disabled');
                    } else {
                        $('#timerText').text('(' + countdown + 's)');
                    }
                }, 1000);
            }

            // Step 1: Submit Register details & Send OTP
            $('#registerForm').on('submit', function(e) {
                e.preventDefault();
                
                var $form = $(this);
                var $btn = $('#btnSendOtp');
                var $spinner = $btn.find('.spinner-border');
                
                userEmail = $form.find('input[name="email"]').val();
                
                // Reset alert messages
                $('#alert-container').empty();
                
                // Show spinner
                $btn.prop('disabled', true);
                $spinner.show();
                
                $.ajax({
                    url: 'register',
                    type: 'POST',
                    data: $form.serialize(),
                    dataType: 'json',
                    success: function(response) {
                        $btn.prop('disabled', false);
                        $spinner.hide();
                        
                        if (response.status === 'success') {
                            // Update UI text display
                            $('#displayEmail').text(userEmail);
                            
                            // Hide the registration form and display OTP inputs
                            $('#registerForm').fadeOut(300, function() {
                                $('#verifyForm').fadeIn(300);
                                startTimer();
                                $('.otp-digit').first().focus();
                                
                                if (response.mock) {
                                    showToast('Development Fallback', 'SMTP failed. Using Mock OTP: ' + response.mockOtp, 'warning');
                                } else {
                                    showToast('Success', 'Verification OTP sent to your email.', 'success');
                                }
                            });

                            // Form transitions to OTP step successfully
                        } else {
                            showAlert('danger', response.message || 'An error occurred during registration.');
                        }
                    },
                    error: function() {
                        $btn.prop('disabled', false);
                        $spinner.hide();
                        showAlert('danger', 'Unable to connect to the server. Please check your internet and try again.');
                    }
                });
            });

            // Step 2: Submit OTP for Verification
            $('#verifyForm').on('submit', function(e) {
                e.preventDefault();
                
                var otp = $('#fullOtp').val();
                if (otp.length !== 6) {
                    showAlert('danger', 'Please enter a complete 6-digit OTP code.');
                    return;
                }

                var $btn = $('#btnVerify');
                var $spinner = $btn.find('.spinner-border');
                
                $('#alert-container').empty();
                $btn.prop('disabled', true);
                $spinner.show();
                
                $.ajax({
                    url: 'verify',
                    type: 'POST',
                    data: { 
                        otp: otp,
                        csrfToken: window.csrfToken
                    },
                    dataType: 'json',
                    success: function(response) {
                        $btn.prop('disabled', false);
                        $spinner.hide();
                        
                        if (response.status === 'success') {
                            // Clear and hide signing option links
                            $('#signinLink').hide();
                            showToast('Success', 'Email verified successfully.', 'success');
                            
                            // Transition to Success Checkmark Screen
                            $('#verifyForm').fadeOut(300, function() {
                                $('#successState').fadeIn(300);
                                setTimeout(function() {
                                    window.location.href = '${pageContext.request.contextPath}/login.jsp?success=1';
                                }, 2000);
                            });
                        } else {
                            showAlert('danger', response.message || 'OTP verification failed.');
                            // Focus first OTP field for correcting
                            $('.otp-digit').val('');
                            $('#fullOtp').val('');
                            $('.otp-digit').first().focus();
                        }
                    },
                    error: function() {
                        $btn.prop('disabled', false);
                        $spinner.hide();
                        showAlert('danger', 'Error verifying code. Please try again.');
                    }
                });
            });

            // Resend OTP Action handler
            $('#btnResend').on('click', function(e) {
                e.preventDefault();
                if ($(this).hasClass('disabled')) return;
                
                var $btn = $(this);
                $btn.addClass('disabled');
                
                $('#alert-container').empty();
                
                $.ajax({
                    url: 'register',
                    type: 'POST',
                    data: $('#registerForm').serialize(),
                    dataType: 'json',
                    success: function(response) {
                        if (response.status === 'success') {
                            showAlert('success', 'A new OTP has been successfully sent.');
                            startTimer();
                            $('.otp-digit').val('').first().focus();
                            $('#fullOtp').val('');
                            
                            // Resent successfully
                        } else {
                            showAlert('danger', response.message || 'Failed to resend verification code.');
                            $btn.removeClass('disabled');
                        }
                    },
                    error: function() {
                        showAlert('danger', 'Unable to resend code. Please try again.');
                        $btn.removeClass('disabled');
                    }
                });
            });

            function showAlert(type, message) {
                var alertClass = type === 'success' ? 'custom-alert' : 'custom-alert-error';
                var icon = type === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill';
                var html = '<div class="' + alertClass + ' text-center">' +
                           '<i class="bi ' + icon + ' me-1"></i> ' + message +
                           '</div>';
                $('#alert-container').html(html);
            }

            // Mock toast utility removed
        });
    </script>
</body>
</html>
