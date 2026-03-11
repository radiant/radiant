import { Controller } from "@hotwired/stimulus"

// Loads tag/filter reference popups and provides tag search filtering.
// Usage:
//   <div data-controller="reference"
//        data-reference-tags-url-value="/admin/references/tags"
//        data-reference-filters-url-value="/admin/references/filters">
//     <a href="#" data-action="reference#loadTags" data-part-slug="body">Available Tags</a>
//     <a href="#" data-action="reference#loadFilter" data-part-slug="body">Filter</a>
//   </div>
export default class extends Controller {
  static values = {
    tagsUrl: String,
    filtersUrl: String,
    pageClassName: { type: String, default: "Page" }
  }

  loadTags(event) {
    event.preventDefault()
    const pageClassInput = document.getElementById("page_class_name")
    const pageClass = pageClassInput ? pageClassInput.value || "Page" : this.pageClassNameValue
    const url = `${this.tagsUrlValue}?class_name=${encodeURIComponent(pageClass)}`

    fetch(url)
      .then(response => response.text())
      .then(html => {
        let existing = document.getElementById("tag_reference_popup")
        if (existing) existing.remove()
        const div = document.createElement("div")
        div.id = "tag_reference_popup"
        div.innerHTML = html
        document.body.appendChild(div)
        this.initTagFilter(div)
      })
  }

  loadFilter(event) {
    event.preventDefault()
    const partSlug = event.currentTarget.getAttribute("data-part-slug")
    const filterSelect = document.getElementById(`part_${partSlug}_filter_id`)
    const filter = filterSelect ? filterSelect.value : ""

    if (filter === "") {
      alert("No documentation for filter.")
      return
    }

    const url = `${this.filtersUrlValue}?filter_name=${encodeURIComponent(filter)}`
    fetch(url)
      .then(response => response.text())
      .then(html => {
        let existing = document.getElementById("filter_reference_popup")
        if (existing) existing.remove()
        const div = document.createElement("div")
        div.id = "filter_reference_popup"
        div.innerHTML = html
        document.body.appendChild(div)
      })
  }

  closePopup(event) {
    event.preventDefault()
    const popup = event.currentTarget.closest(".popup")
    if (popup) {
      popup.closest("[id$='_reference_popup']")?.remove() || (popup.style.display = "none")
    }
  }

  // Tag filter search within a reference popup
  initTagFilter(container) {
    const searchInput = container.querySelector("#search_tag_reference")
    if (!searchInput) return

    const countEl = container.querySelector("#tag_search_found_count")
    let tags = null
    let searchingOn = ""
    let debounceTimer = null

    searchInput.addEventListener("input", () => {
      clearTimeout(debounceTimer)
      debounceTimer = setTimeout(() => {
        const value = searchInput.value
        if (!tags) tags = Array.from(container.querySelectorAll(".reference .tag_description"))
        if (value.length < 3 && searchingOn !== "") {
          searchingOn = ""
          tags.forEach(div => { div.style.display = "" })
          if (countEl) countEl.textContent = `Found ${tags.length} tags`
        } else if (value.length >= 3 && searchingOn !== value) {
          searchingOn = value
          let found = 0
          tags.forEach(div => {
            const h4 = div.querySelector("h4")
            const tagName = h4 ? h4.textContent.toLowerCase() : ""
            const match = tagName.indexOf(value.toLowerCase()) !== -1
            div.style.display = match ? "" : "none"
            if (match) found++
          })
          if (countEl) countEl.textContent = `Found ${found} tags`
        }
      }, 300)
    })
  }
}
