document.addEventListener("turbo:load", () => {
    ["search-form", "pfc-search-form"].forEach((formId) => {
        const form = document.getElementById(formId);
        if(form) {
            console.log("フォームが見つかりました");
            form.addEventListener("submit", (event) => {
                const button = document.getElementById("search-button");
                const spinner = document.getElementById("loading-spinner");
                const loadingScreen = document.getElementById("loading-screen");

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
            console.log("フォームなし")
        };
    });
});
