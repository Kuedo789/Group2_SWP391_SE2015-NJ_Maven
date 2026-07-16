<%-- 
    Document   : scripts
    Created on : Jun 4, 2026, 1:47:50 PM
    Author     : admin
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<script src="${pageContext.request.contextPath}/assets/js/home.js"></script>

<script>
    function showFloatingAlert(msg, type) {
        if (!msg || msg.trim() === "") return;
        let alertDiv = document.createElement('div');
        alertDiv.className = 'custom-floating-alert alert-' + type;
        let icon = type === 'success' 
            ? '<i class="fa-solid fa-circle-check" style="font-size: 18px; margin-right: 10px;"></i>' 
            : '<i class="fa-solid fa-triangle-exclamation" style="font-size: 18px; margin-right: 10px;"></i>';
        alertDiv.innerHTML = icon + '<span>' + msg + '</span>';
        alertDiv.style.cssText = `
            position: fixed;
            top: 24px;
            right: 24px;
            z-index: 10000;
            padding: 14px 24px;
            border-radius: 8px;
            color: white;
            font-family: 'Be Vietnam Pro', sans-serif;
            font-size: 14px;
            font-weight: 500;
            box-shadow: 0 8px 30px rgba(0,0,0,0.15);
            display: flex;
            align-items: center;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            opacity: 0;
            transform: translateY(-20px);
        `;
        if (type === 'success') {
            alertDiv.style.background = 'linear-gradient(135deg, #059669, #10b981)';
        } else {
            alertDiv.style.background = 'linear-gradient(135deg, #dc2626, #ef4444)';
        }
        document.body.appendChild(alertDiv);
        setTimeout(() => {
            alertDiv.style.opacity = '1';
            alertDiv.style.transform = 'translateY(0)';
        }, 50);
        setTimeout(() => {
            alertDiv.style.opacity = '0';
            alertDiv.style.transform = 'translateY(-20px)';
            setTimeout(() => alertDiv.remove(), 400);
        }, 4000);
    }

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

