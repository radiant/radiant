import { Controller } from "@hotwired/stimulus"

// Page editor: manages adding/removing parts and fields.
// Usage:
//   <div data-controller="page-editor"
//        data-page-editor-parts-url-value="/admin/page_parts"
//        data-page-editor-fields-url-value="/admin/page_fields">
export default class extends Controller {
  static targets = ["partName", "addPartButton", "addPartBusy",
                     "partsContainer", "fieldsTable",
                     "addPartPopup", "addFieldPopup", "addFieldName"]
  static values = { partsUrl: String, fieldsUrl: String }

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
      this.closeAddFieldPopup()
      if (this.hasAddFieldNameTarget) this.addFieldNameTarget.value = ""
    })
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
    const name = this.partNameTarget.value.toLowerCase().trim()
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
    if (this.hasAddPartButtonTarget) this.addPartButtonTarget.disabled = true
    if (this.hasAddPartBusyTarget) this.addPartBusyTarget.style.display = ""
  }

  partAdded() {
    if (this.hasAddPartBusyTarget) this.addPartBusyTarget.style.display = "none"
    if (this.hasAddPartButtonTarget) this.addPartButtonTarget.disabled = false
    this.closeAddPartPopup()
    if (this.hasPartNameTarget) this.partNameTarget.value = ""
  }

  closeAddPartPopup() {
    if (this.hasAddPartPopupTarget) {
      this.addPartPopupTarget.style.display = "none"
      const overlay = document.querySelector(`.popup-overlay[data-popup-id="${this.addPartPopupTarget.id}"]`)
      if (overlay) overlay.remove()
    }
  }

  closeAddFieldPopup() {
    if (this.hasAddFieldPopupTarget) {
      this.addFieldPopupTarget.style.display = "none"
      const overlay = document.querySelector(`.popup-overlay[data-popup-id="${this.addFieldPopupTarget.id}"]`)
      if (overlay) overlay.remove()
    }
  }

  get csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ""
  }
}
