import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]
  static values = {
    open: { type: Boolean, default: false },
    status: String
  }

  connect() {
    // Set initial state based on status
    this.updateState()
  }

  statusValueChanged() {
    this.updateState()
  }

  toggle() {
    this.openValue = !this.openValue
    this.toggleContent()
  }

  updateState() {
    if (this.statusValue === "running") {
      this.openValue = true
    }
    this.toggleContent()
  }

  toggleContent() {
    if (this.openValue) {
      this.contentTarget.classList.remove("hidden")
      this.contentTarget.classList.add("block")
      this.iconTarget.classList.add("rotate-180")
      this.element.setAttribute("aria-expanded", "true")
    } else {
      this.contentTarget.classList.remove("block")
      this.contentTarget.classList.add("hidden")
      this.iconTarget.classList.remove("rotate-180")
      this.element.setAttribute("aria-expanded", "false")
    }
  }
} 