import { Controller } from "@hotwired/stimulus"

// Tab control for page parts. Automatically creates tabs from page targets.
// Usage:
//   <div data-controller="tab-control">
//     <div class="tabs" data-tab-control-target="tabs">
//       <div data-tab-control-target="toolbar">...</div>
//     </div>
//     <div class="pages">
//       <div data-tab-control-target="page" data-caption="body">...</div>
//       <div data-tab-control-target="page" data-caption="extended">...</div>
//     </div>
//   </div>
export default class extends Controller {
  static targets = ["tabs", "toolbar", "page"]
  static values = { selectedIndex: { type: Number, default: 0 } }

  connect() {
    this.rebuildTabs()
  }

  pageTargetConnected() {
    this.rebuildTabs()
    // Select the last tab (newly added part)
    if (this.pageTargets.length > 0) {
      this.select(this.pageTargets.length - 1)
    }
  }

  rebuildTabs() {
    // Remove existing tab links (not toolbar)
    this.tabsTarget.querySelectorAll(".tab").forEach(t => t.remove())

    const toolbar = this.hasToolbarTarget ? this.toolbarTarget : null
    this.pageTargets.forEach((page, index) => {
      const caption = page.getAttribute("data-caption") || `Part ${index + 1}`
      const tab = document.createElement("a")
      tab.className = "tab" + (index === this.selectedIndexValue ? " here" : "")
      tab.href = "#"
      tab.innerHTML = `<span>${caption}</span>`
      tab.addEventListener("click", (e) => {
        e.preventDefault()
        this.select(index)
      })

      if (toolbar) {
        this.tabsTarget.insertBefore(tab, toolbar)
      } else {
        this.tabsTarget.appendChild(tab)
      }

      page.style.display = (index === this.selectedIndexValue) ? "" : "none"
    })
  }

  select(index) {
    this.selectedIndexValue = index
    const tabs = this.tabsTarget.querySelectorAll(".tab")
    tabs.forEach((tab, i) => {
      tab.classList.toggle("here", i === index)
    })
    this.pageTargets.forEach((page, i) => {
      page.style.display = (i === index) ? "" : "none"
    })
  }

  removeCurrent() {
    if (!confirm("Remove the current part?")) return

    const tabs = this.tabsTarget.querySelectorAll(".tab")
    const index = this.selectedIndexValue
    const page = this.pageTargets[index]

    if (page) {
      const destroyInput = page.querySelector(".delete_input")
      if (destroyInput) destroyInput.value = "1"
      page.style.display = "none"
      page.removeAttribute("data-tab-control-target")
    }

    if (tabs[index]) tabs[index].remove()

    // Select first remaining tab
    if (this.pageTargets.length > 0) {
      this.select(0)
    }
  }
}
