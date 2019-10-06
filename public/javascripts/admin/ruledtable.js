var RuledTableBehavior = Behavior.create({
  initialize: function() {
    if (Prototype.Browser.IE)
      this.element.
        observe('mouseover', this.onMouseOverRow.bindAsEventListener(this, 'addClassName')).
        observe('mouseout', this.onMouseOverRow.bindAsEventListener(this, 'removeClassName'));
  },
  
  onMouseOverRow: function(event, method) {
    var row = event.findElement('tr');
    if (row) row[method]('hover');
  }
});