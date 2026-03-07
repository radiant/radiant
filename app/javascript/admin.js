// Admin UI behaviors (replaces Prototype.js/lowpro behaviors)

function initAdmin() {
  // Toggle behavior: elements with rel="toggle[targetId]"
  // Clicking toggles visibility of the target element and swaps More/Less text
  document.addEventListener("click", function(e) {
    var link = e.target.closest('a[rel^="toggle["]');
    if (link) {
      e.preventDefault();
      var match = link.getAttribute("rel").match(/toggle\[(.+)\]/);
      if (match) {
        var target = document.getElementById(match[1]);
        if (target) {
          var isHidden = target.style.display === "none";
          target.style.display = isHidden ? "" : "none";
          // Swap More/Less text
          if (link.classList.contains("more")) {
            link.classList.remove("more");
            link.classList.add("less");
            link.textContent = "Less";
          } else if (link.classList.contains("less")) {
            link.classList.remove("less");
            link.classList.add("more");
            link.textContent = "More";
          }
        }
      }
    }
  });

  // Popup helpers
  function showPopup(popup) {
    var overlay = document.createElement("div");
    overlay.className = "popup-overlay";
    overlay.setAttribute("data-popup-id", popup.id);
    document.body.appendChild(overlay);
    popup.style.display = "";
    overlay.addEventListener("click", function() {
      closePopup(popup);
    });
  }

  function closePopup(popup) {
    popup.style.display = "none";
    var overlay = document.querySelector('.popup-overlay[data-popup-id="' + popup.id + '"]');
    if (overlay) overlay.remove();
  }

  window.closePopup = closePopup;

  // Popup behavior: elements with class="popup" and href="#popupId"
  document.addEventListener("click", function(e) {
    var link = e.target.closest('a.popup[href^="#"]');
    if (link) {
      e.preventDefault();
      var targetId = link.getAttribute("href").substring(1);
      var popup = document.getElementById(targetId);
      if (popup) {
        var isHidden = popup.style.display === "none";
        if (isHidden) {
          showPopup(popup);
        } else {
          closePopup(popup);
        }
      }
    }
  });

  // Close popup when clicking a cancel link inside a popup
  document.addEventListener("click", function(e) {
    var cancelLink = e.target.closest("div.popup .cancel");
    if (cancelLink) {
      var popup = cancelLink.closest("div.popup");
      if (popup) {
        closePopup(popup);
      }
    }
  });

  // Tab Control behavior for page parts
  // Reads .page elements inside #tab_control .pages, creates tab buttons,
  // and shows/hides pages when tabs are clicked
  initTabControl();
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initAdmin);
} else {
  initAdmin();
}

function initTabControl() {
  var tabControl = document.getElementById("tab_control");
  if (!tabControl) return;

  var tabsContainer = tabControl.querySelector(".tabs");
  var pagesContainer = tabControl.querySelector(".pages");
  if (!tabsContainer || !pagesContainer) return;

  var pages = pagesContainer.querySelectorAll(".page");
  if (pages.length === 0) return;

  // Preserve the toolbar (add tab button)
  var toolbar = tabsContainer.querySelector("#tab_toolbar");

  // Clear existing tabs (but not toolbar)
  var existingTabs = tabsContainer.querySelectorAll(".tab");
  existingTabs.forEach(function(t) { t.remove(); });

  // Create a tab for each page part
  pages.forEach(function(page, index) {
    var caption = page.getAttribute("data-caption") || "Part " + (index + 1);
    var tab = document.createElement("a");
    tab.className = "tab" + (index === 0 ? " here" : "");
    tab.href = "#";
    tab.innerHTML = "<span>" + caption + "</span>";
    tab.setAttribute("data-tab-index", index);

    tab.addEventListener("click", function(e) {
      e.preventDefault();
      selectTab(tabControl, index);
    });

    // Insert before toolbar if it exists
    if (toolbar) {
      tabsContainer.insertBefore(tab, toolbar);
    } else {
      tabsContainer.appendChild(tab);
    }

    // Show first page, hide others
    page.style.display = (index === 0) ? "" : "none";
  });
}

function selectTab(tabControl, index) {
  var tabs = tabControl.querySelectorAll(".tabs .tab");
  var pages = tabControl.querySelectorAll(".pages > .page");

  tabs.forEach(function(tab, i) {
    if (i === index) {
      tab.classList.add("here");
    } else {
      tab.classList.remove("here");
    }
  });

  pages.forEach(function(page, i) {
    page.style.display = (i === index) ? "" : "none";
  });
}

window.selectTab = selectTab;

// Re-initialize tabs after adding a new part (called from partAdded)
window.refreshTabControl = function() {
  initTabControl();
  // Select the last tab (newly added)
  var tabControl = document.getElementById("tab_control");
  if (tabControl) {
    var pages = tabControl.querySelectorAll(".pages > .page");
    if (pages.length > 0) {
      selectTab(tabControl, pages.length - 1);
    }
  }
};

// Initialize tag filter search on a reference popup
window.initTagFilter = function() {
  var searchInput = document.getElementById("search_tag_reference");
  if (!searchInput) return;
  var popup = searchInput.closest(".popup");
  if (!popup) return;
  var tags = null;
  var searchingOn = "";
  var countEl = document.getElementById("tag_search_found_count");
  var debounceTimer = null;

  searchInput.addEventListener("input", function() {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(function() {
      var value = searchInput.value;
      if (!tags) tags = Array.from(popup.querySelectorAll(".reference .tag_description"));
      if (value.length < 3 && searchingOn !== "") {
        searchingOn = "";
        tags.forEach(function(div) { div.style.display = ""; });
        countEl.textContent = "Found " + tags.length + " tags";
      } else if (value.length >= 3 && searchingOn !== value) {
        searchingOn = value;
        var found = 0;
        tags.forEach(function(div) {
          var h4 = div.querySelector("h4");
          var tagName = h4 ? h4.textContent.toLowerCase() : "";
          var match = tagName.indexOf(value.toLowerCase()) !== -1;
          div.style.display = match ? "" : "none";
          if (match) found++;
        });
        countEl.textContent = "Found " + found + " tags";
      }
    }, 300);
  });
};
