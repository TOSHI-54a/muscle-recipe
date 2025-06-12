import{ Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "menu"]
  contact() {
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }
  toggle() {
    const isExpanded = this.buttonTarget.getAttribute("aria-expanded") === "true"
    this.buttonTarget.setAttribute("aria-expanded", (!isExpanded).toString())
    this.menuTarget.classList.toggle("hidden")
    console.log("🍔🍔")
  }
}