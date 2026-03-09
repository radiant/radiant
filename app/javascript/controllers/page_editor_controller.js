import { Controller } from "@hotwired/stimulus"

// Page editor: manages adding/removing parts and fields.
// Usage:
//   <div data-controller="page-editor"
//        data-page-editor-parts-url-value="/admin/page_parts"
//        data-page-editor-fields-url-value="/admin/page_fields">
export default class extends Controller {
  static targets = ["partsContainer", "fieldsTable"]
  static values = { partsUrl: String, fieldsUrl: String }

  connect() {
    this.addPartHandler = (e) => { this.addPart(e) }
    this.addFieldHandler = (e) => { this.addField(e) }
    const partForm = document.getElementById("new_page_part")
    const fieldForm = document.getElementById("new_page_field")
    if (partForm) partForm.addEventListener("submit", this.addPartHandler)
    if (fieldForm) fieldForm.addEventListener("submit", this.addFieldHandler)
  }

  disconnect() {
    const partForm = document.getElementById("new_page_part")
    const fieldForm = document.getElementById("new_page_field")
    if (partForm) partForm.removeEventListener("submit", this.addPartHandler)
    if (fieldForm) fieldForm.removeEventListener("submit", this.addFieldHandler)
  }

  addPart(event) {
    event.preventDefault()
    if (!this.validatePartName()) return

    this.showPartLoading()
    const form = event.target
    const formData = new FormData(form)

    fetch(this.partsUrlValue, {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": this.csrfToken,
        "Accept": "text/html"
      }
    })
    .then(response => response.text())
    .then(html => {
      this.partsContainerTarget.insertAdjacentHTML("beforeend", html)
      this.partAdded()
    })
    .catch(err => {
      console.error("addPart error:", err)
      this.partAdded()
    })
  }

  addField(event) {
    event.preventDefault()
    const form = event.target
    const formData = new FormData(form)

    fetch(this.fieldsUrlValue, {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": this.csrfToken,
        "Accept": "text/html"
      }
    })
    .then(response => response.text())
    .then(html => {
      this.fieldsTableTarget.insertAdjacentHTML("beforeend", html)
      this.closePopup("add_field_popup")
      const nameField = document.getElementById("page_field_name")
      if (nameField) nameField.value = ""
    })
  }

  showAddPartPopup(event) {
    event.preventDefault()
    this.openPopup("add_part_popup")
  }

  showAddFieldPopup(event) {
    event.preventDefault()
    this.openPopup("add_field_popup")
  }

  removeField(event) {
    event.preventDefault()
    const row = event.currentTarget.closest("tr")
    if (row) {
      const destroyInput = row.querySelector(".delete_input")
      if (destroyInput) destroyInput.value = "1"
      row.style.display = "none"
    }
  }

  // Private

  validatePartName() {
    const nameField = document.getElementById("part_name_field")
    const name = nameField ? nameField.value.toLowerCase().trim() : ""
    if (name === "") {
      alert("Part name cannot be empty.")
      return false
    }
    const tabControl = this.element.querySelector('[data-controller~="tab-control"]')
    if (tabControl) {
      const existingTabs = tabControl.querySelectorAll(".tabs .tab")
      for (let i = 0; i < existingTabs.length; i++) {
        if (existingTabs[i].textContent.trim().toLowerCase() === name) {
          alert("Part name must be unique.")
          return false
        }
      }
    }
    return true
  }

  showPartLoading() {
    const button = document.getElementById("add_part_button")
    const busy = document.getElementById("add_part_busy")
    if (button) button.disabled = true
    if (busy) busy.style.display = ""
  }

  partAdded() {
    const button = document.getElementById("add_part_button")
    const busy = document.getElementById("add_part_busy")
    if (busy) busy.style.display = "none"
    if (button) button.disabled = false
    this.closePopup("add_part_popup")
    const nameField = document.getElementById("part_name_field")
    if (nameField) nameField.value = ""
  }

  openPopup(id) {
    const dialog = document.getElementById(id)
    if (!dialog) return
    const overlay = document.createElement("div")
    overlay.className = "popup-overlay"
    overlay.setAttribute("data-popup-id", id)
    overlay.addEventListener("click", () => {
      dialog.style.display = "none"
      overlay.remove()
    })
    document.body.appendChild(overlay)
    dialog.style.display = ""
  }

  closePopup(id) {
    const dialog = document.getElementById(id)
    if (dialog) {
      dialog.style.display = "none"
      const overlay = document.querySelector(`.popup-overlay[data-popup-id="${id}"]`)
      if (overlay) overlay.remove()
    }
  }

  get csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ""
  }
}
