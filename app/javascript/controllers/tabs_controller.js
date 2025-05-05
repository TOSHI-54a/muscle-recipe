import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    this.showTab(0)
  }

  showTab(index) {
    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("border-b-2", i === index)
      tab.classList.toggle("border-blue-500", i === index)
      tab.classList.toggle("text-blue-500", i === index)
    })

    this.panelTargets.forEach((panel, i) => {
      panel.classList.toggle("hidden", i !== index)
    })
  }

  change(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.showTab(index)
  }
}
