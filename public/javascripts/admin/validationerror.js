var ValidationErrorBehavior = Behavior.create({
  initialize: function() {
    new ValidationError(this.element);
  }
});

var ValidationError = Class.create({
  initialize: function(element) {
    this.element = $(element);
    this.closer = new Element('a', {'href' : '#', 'class' : 'closer' }).update("x");
    this.closer.observe('click', this.hide.bindAsEventListener(this));
    this.element.insert(this.closer, {position : 'top'});
  },
  hide: function (event) {
    event.stop();
    this.element.fade();
  }
});