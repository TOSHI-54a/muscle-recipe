import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["background", "content"]
    connect() {
        console.log("🚀 Modal controller connected", this.element)
      }

    open() {
        console.log("🪐宇宙")
        this.element.classList.remove("hidden")
    }

    close(event) {
        if (event.target === this.backgroundTarget || event.currentTarget.dataset.action?.includes("close")) {
            this.element.classList.add("hidden")
        }
    }
}