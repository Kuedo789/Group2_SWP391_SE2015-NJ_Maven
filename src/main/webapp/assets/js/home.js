document.addEventListener("DOMContentLoaded", function () {
    const slides = document.querySelectorAll(".hero-slide");
    const dotsContainer = document.querySelector(".hero-dots");

    if (!slides.length || !dotsContainer) {
        return;
    }

    let currentIndex = 0;
    const delay = 4000;
    let timer = null;

    slides.forEach(function (_, index) {
        const dot = document.createElement("button");
        dot.type = "button";
        dot.setAttribute("aria-label", "Chuyển đến slide " + (index + 1));

        if (index === 0) {
            dot.classList.add("active");
        }

        dot.addEventListener("click", function () {
            showSlide(index);
            restartTimer();
        });

        dotsContainer.appendChild(dot);
    });

    const dots = dotsContainer.querySelectorAll("button");

    // Left/Right navigation buttons click handlers
    const prevBtn = document.getElementById("heroPrevBtn");
    const nextBtn = document.getElementById("heroNextBtn");

    if (prevBtn) {
        prevBtn.addEventListener("click", function () {
            const prevIndex = (currentIndex - 1 + slides.length) % slides.length;
            showSlide(prevIndex);
            restartTimer();
        });
    }

    if (nextBtn) {
        nextBtn.addEventListener("click", function () {
            const nextIndex = (currentIndex + 1) % slides.length;
            showSlide(nextIndex);
            restartTimer();
        });
    }

    function showSlide(index) {
        slides[currentIndex].classList.remove("active");
        dots[currentIndex].classList.remove("active");

        currentIndex = index;

        slides[currentIndex].classList.add("active");
        dots[currentIndex].classList.add("active");
    }

    function nextSlide() {
        const nextIndex = (currentIndex + 1) % slides.length;
        showSlide(nextIndex);
    }

    function startTimer() {
        timer = setInterval(nextSlide, delay);
    }

    function restartTimer() {
        clearInterval(timer);
        startTimer();
    }

    startTimer();
});