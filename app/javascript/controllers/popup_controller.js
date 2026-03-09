import { Controller } from "@hotwired/stimulus"

// Manages popup dialogs with overlay backdrop.
// Usage:
//   <div data-controller="popup">
//     <a href="#" data-action="popup#open">Open</a>
//     <div data-popup-target="dialog" style="display: none" class="popup">
//       ...
//       <a href="#" data-action="popup#close" class="cancel">Cancel</a>
//     </div>
//   </div>
export default class extends Controller {
  static targets = ["dialog"]

  open(event) {
    event.preventDefault()
    const dialog = this.dialogTarget
    const overlay = document.createElement("div")
    overlay.className = "popup-overlay"
    overlay.setAttribute("data-popup-id", dialog.id)
    overlay.addEventListener("click", () => this.close(event))
    document.body.appendChild(overlay)
    dialog.style.display = ""
  }

  close(event) {
    if (event) event.preventDefault()
    const dialog = this.dialogTarget
    dialog.style.display = "none"
    const overlay = document.querySelector(`.popup-overlay[data-popup-id="${dialog.id}"]`)
    if (overlay) overlay.remove()
  }
}
