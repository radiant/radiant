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

  // Popup behavior: elements with class="popup" and href="#popupId"
  // Clicking toggles visibility of the referenced popup element
  document.addEventListener("click", function(e) {
    var link = e.target.closest('a.popup[href^="#"]');
    if (link) {
      e.preventDefault();
      var targetId = link.getAttribute("href").substring(1);
      var popup = document.getElementById(targetId);
      if (popup) {
        var isHidden = popup.style.display === "none";
        popup.style.display = isHidden ? "" : "none";
      }
    }
  });
});
