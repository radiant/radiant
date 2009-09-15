// String extensions
Object.extend(String.prototype, {
  upcase: function() {
    return this.toUpperCase();
  },

  downcase: function() {
    return this.toLowerCase();
  },
  
  toInteger: function() {
    return parseInt(this);
  },
  
  toSlug: function() {
    return this.strip().downcase().replace(/[^-a-z0-9~\s\.:;+=_]/g, '').replace(/[\s\.:;=+]+/g, '-');
  }
});

// Element extensions
Element.addMethods({
  hasWord: function(element, word) {
    element = $(element);
    if (element.nodeType == Node.TEXT_NODE) {
      return element.nodeValue.include(word);
    } else {
      return $A(element.childNodes).any(function(child) { 
        return Element.hasWord(child, word); 
      });
    }
  },

  centerInViewport: function(element) {
    var header = $('header')
    var headerBottom = header.getHeight();
    var viewport = document.viewport.getScrollOffsets();
    viewport.height = document.viewport.getHeight();
    viewport.width = document.viewport.getWidth();
    viewport.bottom = viewport.top + viewport.height;
    viewport.top = Math.max(viewport.top, headerBottom);
    viewport.height = viewport.bottom - viewport.top;
    element.style.position = 'absolute';
    element.style.top = (viewport.top + (viewport.height - element.getHeight()) / 2.5) + 'px';
    element.style.left = (viewport.left + (viewport.width - element.getWidth()) / 2) + 'px';
  }
});

Popup.AbstractWindow.addMethods({
  centerWindowInView: function() {
    this.element.centerInViewport();
  }
});