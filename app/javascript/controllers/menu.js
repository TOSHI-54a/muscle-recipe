document.addEventListener("turbo:load", () => {
    const toggleButton = document.querySelector("[data-collapse-toggle]");
    const navbarMenu = document.getElementById("navbar-sticky");

    if (toggleButton && navbarMenu) {
        toggleButton.addEventListener("click", () => {
            navbarMenu.classList.toggle("hidden");
        });
    }

    // ✅ 画面サイズ変更時に `md:` 以上なら `hidden` を削除（常時表示）
    const checkScreenSize = () => {
        if (window.innerWidth >= 768) {
            navbarMenu.classList.remove("hidden"); // PC時は常時表示
        } else {
            navbarMenu.classList.add("hidden"); // スマホ時は非表示
        }
    };

    // ✅ 初回読み込み時のチェック
    checkScreenSize();

    // ✅ 画面リサイズ時にも適用
    window.addEventListener("resize", checkScreenSize);
});