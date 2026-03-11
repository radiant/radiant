import { Controller } from "@hotwired/stimulus"

// Toggles between password display and password change fields.
// Usage:
//   <div data-controller="password-toggle">
//     <p data-password-toggle-target="display">
//       <a href="#" data-action="password-toggle#showChange">Change</a>
//     </p>
//     <div data-password-toggle-target="change" style="display: none">
//       ...
//       <a href="#" data-action="password-toggle#showDisplay">Cancel</a>
//     </div>
//   </div>
export default class extends Controller {
  static targets = ["display", "change"]

  showChange(event) {
    event.preventDefault()
    this.displayTarget.style.display = "none"
    this.changeTarget.style.display = ""
  }

  showDisplay(event) {
    event.preventDefault()
    this.displayTarget.style.display = ""
    this.changeTarget.style.display = "none"
  }
}
