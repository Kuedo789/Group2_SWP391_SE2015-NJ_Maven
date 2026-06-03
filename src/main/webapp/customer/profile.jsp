<%-- 
    Document   : profile
    Created on : Jun 3, 2026, 4:56:53 PM
    Author     : Nguyễn Hùng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Update Profile - CakeZone</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f8f5f0;
            font-family: Arial, sans-serif;
        }

        .navbar {
            background-color: #2b1b17;
        }

        .navbar-brand {
            color: #e88f2a !important;
            font-weight: bold;
            font-size: 28px;
            text-transform: uppercase;
        }

        .navbar .nav-link {
            color: #ddd !important;
        }

        .navbar .nav-link:hover,
        .navbar .nav-link.active {
            color: #e88f2a !important;
        }

        .profile-section {
            padding: 60px 0;
        }

        .profile-card {
            background-color: #ffffff;
            border-radius: 14px;
            box-shadow: 0 0 22px rgba(0, 0, 0, 0.08);
            padding: 40px;
        }

        .avatar-box {
            text-align: center;
            margin-bottom: 25px;
        }

        .profile-avatar {
            width: 125px;
            height: 125px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid #e88f2a;
        }

        .avatar-name {
            margin-top: 12px;
            font-weight: bold;
            color: #2b1b17;
        }

        .form-title {
            color: #2b1b17;
            font-weight: bold;
            margin-bottom: 25px;
        }

        .form-label {
            font-weight: 600;
            color: #222;
        }

        .form-control {
            border-radius: 8px;
            padding: 10px 12px;
        }

        .form-control:focus {
            border-color: #e88f2a;
            box-shadow: 0 0 0 0.2rem rgba(232, 143, 42, 0.2);
        }

        .small-note {
            font-size: 13px;
            color: #777;
        }

        .btn-update {
            background-color: #e88f2a;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 10px 28px;
            font-weight: bold;
        }

        .btn-update:hover {
            background-color: #d17b1d;
            color: white;
        }

        .btn-cancel {
            border-radius: 8px;
            padding: 10px 28px;
        }
    </style>
</head>

<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark px-5 py-3">
    <a href="${pageContext.request.contextPath}/index.jsp" class="navbar-brand">
        <i class="fa fa-birthday-cake me-2"></i>CAKEZONE
    </a>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarCollapse">
        <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarCollapse">
        <div class="navbar-nav ms-auto">

            <a href="${pageContext.request.contextPath}/index.jsp" class="nav-item nav-link">
                Home
            </a>

            <div class="nav-item dropdown">
                <a href="#" class="nav-link dropdown-toggle active" data-bs-toggle="dropdown">
                    <i class="fa fa-user me-1"></i>
                    ${sessionScope.user.fullName}
                </a>

                <div class="dropdown-menu dropdown-menu-end">
                    <a href="${pageContext.request.contextPath}/customer/profile.jsp" class="dropdown-item">
                        Update Profile
                    </a>
                    <a href="${pageContext.request.contextPath}/logout" class="dropdown-item">
                        Logout
                    </a>
                </div>
            </div>

        </div>
    </div>
</nav>

<!-- Profile Section -->
<div class="container profile-section">
    <div class="row justify-content-center">
        <div class="col-lg-8 col-md-10">

            <div class="profile-card">
                
                <h3 class="form-title">
                    <i class="fa fa-user-pen me-2"></i>
                    Update Profile
                </h3>
                <!-- Avatar -->
                <div class="avatar-box">
                    <img src="${pageContext.request.contextPath}/img/user-default.png"
                         alt="User Avatar"
                         class="profile-avatar">

                    <h5 class="avatar-name">${sessionScope.user.fullName}</h5>
                </div>

                <% if (request.getAttribute("success") != null) { %>
                    <div class="alert alert-success">
                        Profile updated successfully.
                    </div>
                <% } %>

                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger">
                        ${error}
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/profile/update" method="post">

                    <div class="row">

                        <div class="col-md-6 mb-3">
                            <label class="form-label">
                                Full Name <span class="text-danger">*</span>
                            </label>
                            <input type="text"
                                   name="fullName"
                                   class="form-control"
                                   value="${sessionScope.user.fullName}"
                                   placeholder="Enter your full name"
                                   required>
                        </div>

                        <div class="col-md-6 mb-3">
                            <label class="form-label">
                                Phone Number <span class="text-danger">*</span>
                            </label>
                            <input type="text"
                                   name="phone"
                                   class="form-control"
                                   value="${sessionScope.user.phone}"
                                   placeholder="Enter phone number"
                                   required>
                        </div>

                        <div class="col-md-12 mb-3">
                            <label class="form-label">Email</label>
                            <input type="email"
                                   name="email"
                                   class="form-control"
                                   value="${sessionScope.user.email}"
                                   readonly>
                            <div class="small-note mt-1">
                                Email is used for login and cannot be changed here.
                            </div>
                        </div>

                        <div class="col-md-12 mb-3">
                            <label class="form-label">
                                Delivery Address <span class="text-danger">*</span>
                            </label>
                            <textarea name="address"
                                      class="form-control"
                                      rows="4"
                                      placeholder="Enter your delivery address"
                                      required>${sessionScope.user.address}</textarea>
                        </div>

                    </div>

                    <div class="d-flex justify-content-end gap-2 mt-3">
                        <a href="${pageContext.request.contextPath}/index.jsp"
                           class="btn btn-secondary btn-cancel">
                            Cancel
                        </a>

                        <button type="submit" class="btn btn-update">
                            <i class="fa fa-save me-2"></i>
                            Update Profile
                        </button>
                    </div>

                </form>

            </div>

        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>