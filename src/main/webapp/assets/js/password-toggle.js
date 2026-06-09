document.addEventListener("DOMContentLoaded", function () {
    const toggleIcons = document.querySelectorAll(".toggle-password");

    toggleIcons.forEach(function (icon) {
        icon.addEventListener("click", function () {
            const inputId = icon.getAttribute("data-target");
            const input = document.getElementById(inputId);

            if (!input) return;

            if (input.type === "password") {
                input.type = "text";
                icon.textContent = "visibility_off";
            } else {
                input.type = "password";
                icon.textContent = "visibility";
            }
        });
    });
});