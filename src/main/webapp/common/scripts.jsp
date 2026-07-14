<%-- 
    Document   : scripts
    Created on : Jun 4, 2026, 1:47:50 PM
    Author     : admin
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<script src="${pageContext.request.contextPath}/assets/js/home.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        // Toggle user profile dropdown menu
        const userBtn = document.getElementById("userDropdownBtn");
        const userMenu = document.getElementById("userDropdownMenu");

        if (userBtn && userMenu) {
            userBtn.addEventListener("click", function(e) {
                e.stopPropagation();
                const isShown = userMenu.classList.contains("show");
                if (isShown) {
                    userMenu.classList.remove("show");
                } else {
                    userMenu.classList.add("show");
                }
            });

            document.addEventListener("click", function() {
                userMenu.classList.remove("show");
            });

            userMenu.addEventListener("click", function(e) {
                e.stopPropagation();
            });
        }

        // Handle search form validation
        const navSearchForm = document.getElementById("navSearchForm");
        if (navSearchForm) {
            navSearchForm.addEventListener("submit", function (event) {
                const input = navSearchForm.querySelector("input[name='search']");
                const keyword = input ? input.value.trim() : "";
                if (keyword.length === 0) {
                    event.preventDefault();
                    if (input) {
                        input.focus();
                    }
                }
            });
        }
    });
</script>

