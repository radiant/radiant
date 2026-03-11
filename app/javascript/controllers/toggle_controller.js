import { Controller } from "@hotwired/stimulus"

// Toggles visibility of a target element.
// Usage:
//   <div data-controller="toggle" data-toggle-open-value="false">
//     <a href="#" data-action="toggle#toggle" data-toggle-target="link">More</a>
//     <div data-toggle-target="content" style="display: none">...</div>
//   </div>
export default class extends Controller {
  static targets = ["content", "link"]
  static values = { open: { type: Boolean, default: false } }

  toggle(event) {
    event.preventDefault()
    this.openValue = !this.openValue
  }

  openValueChanged() {
    this.contentTargets.forEach(el => {
      el.style.display = this.openValue ? "" : "none"
    })
    this.linkTargets.forEach(link => {
      if (this.openValue) {
        link.classList.remove("more")
        link.classList.add("less")
        link.textContent = "Less"
      } else {
        link.classList.remove("less")
        link.classList.add("more")
        link.textContent = "More"
      }
    })
  }
}
