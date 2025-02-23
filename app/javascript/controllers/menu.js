document.addEventListener("turbo:load", () => {
    const toggleButton = document.querySelector("[data-collapse-toggle]");
    const navbarMenu = document.getElementById("navbar-sticky");

    if (toggleButton && navbarMenu) {
        toggleButton.addEventListener("click", () => {
            navbarMenu.classList.toggle("hidden");
        });
    }

    function updateNavbarState() {
        if (window.innerWidth >= 768) {
            navbarMenu.classList.remove("hidden");
            navbarMenu.style.width = "auto";
        } else {
            navbarMenu.classList.add("hidden");
            navbarMenu.style.width = "100%";
        }
    }

    // ✅ 初回ロード時の適用
    updateNavbarState();

    // ✅ 画面リサイズ時に適用
    window.addEventListener("resize", updateNavbarState);
});
