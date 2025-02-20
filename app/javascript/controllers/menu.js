document.addEventListener("turbo:load", () => {
    const toggleButton = document.querySelector("[data-collapse-toggle]");
    const navbarMenu = document.getElementById("navbar-sticky");
  
    if (toggleButton && navbarMenu) {
      toggleButton.addEventListener("click", () => {
        const expanded = toggleButton.getAttribute("aria-expanded") === "true";
        toggleButton.setAttribute("aria-expanded", !expanded);
        navbarMenu.classList.toggle("hidden");
      });
    }
  });
  