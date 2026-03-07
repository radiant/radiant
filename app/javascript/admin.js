// Admin UI behaviors (replaces Prototype.js/lowpro behaviors)

document.addEventListener("DOMContentLoaded", function() {
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
    // Create overlay backdrop
    var overlay = document.createElement("div");
    overlay.className = "popup-overlay";
    overlay.setAttribute("data-popup-id", popup.id);
    document.body.appendChild(overlay);

    popup.style.display = "";

    // Close on overlay click
    overlay.addEventListener("click", function() {
      closePopup(popup);
    });
  }

  function closePopup(popup) {
    popup.style.display = "none";
    var overlay = document.querySelector('.popup-overlay[data-popup-id="' + popup.id + '"]');
    if (overlay) overlay.remove();
  }

  // Make closePopup available globally for inline onclick handlers
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
});
