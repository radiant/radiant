import { Controller } from "@hotwired/stimulus"

// Dropdown menu that appears on click, positioned below the trigger.
// Usage:
//   <span data-controller="dropdown">
//     <a href="#" data-action="dropdown#toggle">Add Child</a>
//     <ul data-dropdown-target="menu" class="menu">...</ul>
//   </span>
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.closeHandler = (e) => {
      if (!this.element.contains(e.target)) this.hide()
    }
    this.hideHandler = () => this.hide()
    document.addEventListener("click", this.closeHandler)
    window.addEventListener("scroll", this.hideHandler, true)
    window.addEventListener("resize", this.hideHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.closeHandler)
    window.removeEventListener("scroll", this.hideHandler, true)
    window.removeEventListener("resize", this.hideHandler)
  }

  toggle(event) {
    event.preventDefault()
    const menu = this.menuTarget
    const isVisible = menu.classList.contains("visible")

    // Close all other dropdowns first
    document.querySelectorAll("ul.menu.visible").forEach(m => {
      if (m !== menu) m.classList.remove("visible")
    })

    if (isVisible) {
      this.hide()
    } else {
      const rect = event.currentTarget.getBoundingClientRect()
      menu.style.top = (rect.bottom + 1) + "px"
      menu.classList.add("visible")
      menu.style.left = (rect.right - menu.offsetWidth) + "px"
    }
  }

  hide() {
    this.menuTarget.classList.remove("visible")
  }
}
