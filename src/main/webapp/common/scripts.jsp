<%-- 
    Document   : scripts
    Created on : Jun 4, 2026, 1:47:50 PM
    Author     : admin
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<script src="${pageContext.request.contextPath}/assets/js/home.js"></script>

<script>
    const userDropdownBtn = document.getElementById("userDropdownBtn");
    const userDropdownMenu = document.getElementById("userDropdownMenu");

    if (userDropdownBtn && userDropdownMenu) {
        userDropdownBtn.addEventListener("click", function (event) {
            event.stopPropagation();
            userDropdownMenu.classList.toggle("show");
        });

        document.addEventListener("click", function () {
            userDropdownMenu.classList.remove("show");
        });

        userDropdownMenu.addEventListener("click", function (event) {
            event.stopPropagation();
        });
    }
</script>