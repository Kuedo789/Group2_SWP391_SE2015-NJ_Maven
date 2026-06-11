<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    request.setAttribute("pageTitle", "Đăng ký tài khoản");

    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");

    String fullName = (String) request.getAttribute("fullName");
    String email = (String) request.getAttribute("email");
    String phone = (String) request.getAttribute("phone");

    if (fullName == null) {
        fullName = "";
    }

    if (email == null) {
        email = "";
    }

    if (phone == null) {
        phone = "";
    }
%>

<!DOCTYPE html>
<html lang="vi">

<head>
    <jsp:include page="../common/header.jsp" />
</head>

<body>

<jsp:include page="../common/navbar.jsp" />

<main class="main auth-main">

    <section class="auth-section">

        <div class="auth-card">

            <!-- LEFT -->
            <div class="auth-visual register-visual">

                <div class="auth-badge">
                    <span class="material-symbols-outlined">cake</span>
                    Thành viên tiệm bánh
                </div>

                <h1>Tạo tài khoản để đặt bánh dễ dàng hơn</h1>

                <p>
                    Đăng ký tài khoản để theo dõi đơn hàng, lưu thông tin giao hàng
                    và nhận các ưu đãi dành riêng cho thành viên.
                </p>

                <div class="auth-benefits">

                    <div>
                        <span class="material-symbols-outlined">wand_stars</span>
                        Tự thiết kế chiếc bánh của riêng bạn
                    </div>

                    <div>
                        <span class="material-symbols-outlined">receipt_long</span>
                        Theo dõi lịch sử đơn hàng
                    </div>

                    <div>
                        <span class="material-symbols-outlined">redeem</span>
                        Nhận ưu đãi thành viên
                    </div>

                </div>

            </div>

            <!-- RIGHT -->
            <div class="auth-form-wrap">

                <div class="auth-form-header">
                    <span class="auth-label">Đăng ký</span>
                    <h2>Tạo tài khoản mới</h2>
                </div>

                <% if (error != null) { %>
                    <div class="auth-message auth-error">
                        <span class="material-symbols-outlined">error</span>
                        <%= error %>
                    </div>
                <% } %>

                <% if (message != null) { %>
                    <div class="auth-message auth-success">
                        <span class="material-symbols-outlined">check_circle</span>
                        <%= message %>
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/register"
                      method="post"
                      class="auth-form">

                    <div class="form-group">
                        <label for="fullName">Họ và tên</label>

                        <div class="input-wrap">
                            <span class="material-symbols-outlined input-icon">person</span>

                            <input type="text"
                                   id="fullName"
                                   name="fullName"
                                   value="<%= fullName %>"
                                   placeholder="Nhập họ và tên"
                                   maxlength="100"
                                   pattern="^[A-Za-zÀ-ỹ]+( [A-Za-zÀ-ỹ]+)*$"
                                   title="Họ tên chỉ được chứa chữ cái và không được có nhiều hơn 1 khoảng trắng liên tiếp"
                                   required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="email">Email</label>

                        <div class="input-wrap">
                            <span class="material-symbols-outlined input-icon">alternate_email</span>

                            <input type="email"
                                   id="email"
                                   name="email"
                                   value="<%= email %>"
                                   placeholder="Nhập email của bạn"
                                   maxlength="100"
                                   required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="phone">Số điện thoại</label>

                        <div class="input-wrap">
                            <span class="material-symbols-outlined input-icon">phone</span>

                            <input type="tel"
                                   id="phone"
                                   name="phone"
                                   value="<%= phone %>"
                                   placeholder="Nhập số điện thoại"
                                   maxlength="10"
                                   pattern="^(?!([0-9])\1{9}$)0[0-9]{9}$"
                                   title="Số điện thoại phải bắt đầu bằng 0, có đúng 10 chữ số và không được là 10 số giống nhau"
                                   required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="password">Mật khẩu</label>

                        <div class="input-wrap">
                            <span class="material-symbols-outlined input-icon">lock</span>

                            <input type="password"
                                   id="password"
                                   name="password"
                                   placeholder="Nhập mật khẩu"
                                   minlength="6"
                                   maxlength="20"
                                   pattern="^\S+$"
                                   title="Mật khẩu phải từ 6 đến 20 ký tự và không được chứa khoảng trắng"
                                   required>

                            <span class="material-symbols-outlined toggle-password"
                                  data-target="password">
                                visibility
                            </span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="confirmPassword">Xác nhận mật khẩu</label>

                        <div class="input-wrap">
                            <span class="material-symbols-outlined input-icon">lock_reset</span>

                            <input type="password"
                                   id="confirmPassword"
                                   name="confirmPassword"
                                   placeholder="Nhập lại mật khẩu"
                                   minlength="6"
                                   maxlength="20"
                                   pattern="^\S+$"
                                   title="Mật khẩu xác nhận không được chứa khoảng trắng"
                                   required>

                            <span class="material-symbols-outlined toggle-password"
                                  data-target="confirmPassword">
                                visibility
                            </span>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary auth-submit">
                        Đăng ký
                    </button>

                    <div class="auth-switch">
                        Đã có tài khoản?
                        <a href="${pageContext.request.contextPath}/login">
                            Đăng nhập
                        </a>
                    </div>

                </form>

            </div>

        </div>

    </section>

</main>

<jsp:include page="../common/footer.jsp" />
<jsp:include page="../common/scripts.jsp" />
<script src="${pageContext.request.contextPath}/assets/js/password-toggle.js"></script>

</body>
</html>