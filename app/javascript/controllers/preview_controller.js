import { Controller } from "@hotwired/stimulus"

// Page preview: submits form data to preview endpoint in an iframe overlay.
// Usage:
//   <div data-controller="preview" data-preview-url-value="/admin/pages/preview">
//     <button data-action="preview#show">Preview</button>
//     <div data-preview-target="panel" style="display: none">
//       <iframe data-preview-target="frame" name="page-preview"></iframe>
//       <div data-preview-target="tools">
//         <a href="#" data-action="preview#close" class="cancel">Back to editor</a>
//       </div>
//     </div>
//   </div>
export default class extends Controller {
  static targets = ["panel", "frame", "tools"]
  static values = { url: String }

  show(event) {
    event.preventDefault()
    const form = this.element.closest("form") || this.element.querySelector("form")
    if (!form) return

    window.scrollTo(0, 0)
    this.panelTarget.style.display = ""
    this.toolsTarget.style.opacity = "1"
    document.body.classList.add("clipped")

    // Create a hidden form targeting the iframe to avoid Turbo interception
    const previewForm = document.createElement("form")
    previewForm.method = "POST"
    previewForm.action = this.urlValue
    previewForm.target = this.frameTarget.name
    previewForm.style.display = "none"
    previewForm.setAttribute("data-turbo", "false")

    const formData = new FormData(form)
    formData.delete("_method")
    for (const [name, value] of formData.entries()) {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = name
      input.value = value
      previewForm.appendChild(input)
    }

    document.body.appendChild(previewForm)
    previewForm.submit()
    previewForm.remove()
  }

  frameLoaded() {
    this.toolsTarget.style.opacity = null
  }

  close(event) {
    event.preventDefault()
    this.panelTarget.style.display = "none"
    document.body.classList.remove("clipped")
    this.frameTarget.src = "about:blank"
  }
}
