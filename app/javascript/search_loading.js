document.addEventListener("turbo:load", () => {
    console.log("⭐️ JS loading - search_loading.js");
    const form = document.getElementById("search-form");
    const button = document.getElementById("search-button");
    const spinner = document.getElementById("loading-spinner");
    const loadingScreen = document.getElementById("loading-screen");

    if(form) {
        console.log("フォームが見つかりました");
        form.addEventListener("submit", (event) => {
            console.log("検索フォームが送信されました");
            if(button) {
                button.disabled = true;
                button.classList.add("opacity-50", "cursor-not-allowed");
            }
            if(spinner) {
                spinner.classList.remove("hidden");
            }
            if(loadingScreen) {
                loadingScreen.classList.remove("hidden");
            }
        });
    } else {
        console.log("フォームなし");
    };
});