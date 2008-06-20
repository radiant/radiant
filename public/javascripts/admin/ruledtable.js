var RuledTable = Class.create({
  initialize: function(element) {
    if (Prototype.Browser.IE)
      $(element).
        observe('mouseover', this.onMouseOverRow.bindAsEventListener(this, 'addClassName')).
        observe('mouseout', this.onMouseOverRow.bindAsEventListener(this, 'removeClassName'));
  },
  
  onMouseOverRow: function(event, method) {
    var row = event.findElement('tr');
    if (row) row[method]('highlight');
  }
});
