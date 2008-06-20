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
