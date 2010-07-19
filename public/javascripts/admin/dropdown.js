/*
 *  dropdown.js
 *
 *  dependencies: prototype.js, effects.js, lowpro.js
 *
 *  --------------------------------------------------------------------------
 *  
 *  Allows you to easily create a dropdown menu item. Simply create a link
 *  with a class of "dropdown" that references the ID of the list that you
 *  would like to use as a dropdown menu.
 *  
 *  A link like this:
 *  
 *    <a class="dropdown" href="#dropdown">Menu</a>
 *  
 *  will dropdown a list of choices in the list with the ID of "dropdown".
 *  
 *  You will need to install the following hook:
 *  
 *    Event.addBehavior({'a.dropdown': Dropdown.TriggerBehavior()});
 *  
 *  --------------------------------------------------------------------------
 *  
 *  Copyright (c) 2010, John W. Long
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining a
 *  copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *  DEALINGS IN THE SOFTWARE.
 *  
 */

var Dropdown = {
  
  DefaultPosition: 'bottom',
  
  DefaultEffect: 'slide',
  DefaultEffectDuration: 0.1,
  
  EffectPairs: {
    'slide' : ['SlideDown', 'SlideUp'],
    'blind' : ['BlindDown', 'BlindUp'],
    'appear': ['Appear', 'Fade']
  }
  
};

Dropdown.TriggerBehavior = Behavior.create({
  initialize: function(options) {
    var options = options || {};
    options.position = (options.position || Dropdown.DefaultPosition).toLowerCase();
    options.effect = (options.effect || Dropdown.DefaultEffect).toLowerCase();
    options.duration = (options.duration || Dropdown.DefaultEffectDuration);
    this.options = options;
    
    var matches = this.element.href.match(/\#(.+)$/);
    this.menu = (matches ? Dropdown.Menu.findOrCreate(matches[1]) : new Dropdown.AjaxMenu(this.element.href));
  },
  
  onclick: function(event) {
    event.stop();
    if (this.menu) this.menu.toggle(this.element, this.options);
  }
});

Dropdown.Menu = Class.create({
  
  initialize: function(element) {
    element.remove();
    this.element = element;
    this.wrapper = $div({'class': 'dropdown_wrapper', 'style': 'position: absolute; display: none'}, element);
    document.body.insert(this.wrapper);
  },
  
  open: function(trigger, options) {
    this.wrapper.hide();
    trigger.addClassName('selected');
    this.position(trigger, options);
    var name = options.effect;
    var effect = Effect[Dropdown.EffectPairs[name][0]];
    effect(this.wrapper, {duration: options.duration});
  },
  
  close: function(trigger, options) {
    var name = options.effect;
    var effect = Effect[Dropdown.EffectPairs[name][1]];
    effect(this.wrapper, {duration: options.duration});
    trigger.removeClassName('selected');
  },
  
  toggle: function(trigger, options) {
    if (this.lastTrigger == trigger) {
      if (this.wrapper.visible()) {
        this.close(trigger, options);
      } else {
        this.open(trigger, options);
      }
    } else {
      if (this.lastTrigger) this.lastTrigger.removeClassName('selected');
      this.open(trigger, options);
    }
    this.lastTrigger = trigger;
  },
  
  position: function(trigger, options) {
    switch(options.position) {
      case 'top':     this.positionTop(trigger);     break;
      case 'bottom':  this.positionBottom(trigger);  break;
      default:        this.positionBottom(trigger);
    }
    this.lastOptions = options;
  },
  
  positionTop: function(trigger) {
    var offset = trigger.cumulativeOffset();
    var height = this.wrapper.getHeight();
    this.wrapper.setStyle({
      left: offset.left + 'px',
      top:  (offset.top - height) + 'px'
    });
    this.lastTrigger = trigger;
  },
  
  positionBottom: function(trigger) {
    var offset = trigger.cumulativeOffset();
    var height = trigger.getHeight();
    this.wrapper.setStyle({
      left: offset.left + 'px',
      top:  (offset.top + height) + 'px'
    });
    this.lastTrigger = trigger;
  },
  
  reposition: function() {
    if (this.lastTrigger) this.position(this.lastTrigger, this.lastOptions);
  },
  
  visible: function() {
    return this.wrapper.visible();
  }
  
});

Dropdown.AjaxMenu = Class.create(Dropdown.Menu, {
  initialize: function(url) {
    this.url = url;
    this.element = $ul({'class': 'menu'});
    this.wrapper = $div({'class': 'dropdown_wrapper', 'style': 'position: absolute; display: none'}, this.element);
    document.body.insert(this.wrapper);
  },

  open: function($super, trigger, options) {
    if (!this.loaded) {
      new Ajax.Request(this.url, {
        asynchronous: false,
        method: 'get',
        evalScripts: true,
        onSuccess: function(data) {
          var menu = new Element('ul',{'class':'menu'}).update(data.responseText);
          var links = menu.childElements($$('li'));
          if (links.length == 1) {
            window.location = links[0].down().href;
          } else {
            this.element.replace(menu);
            $super(trigger, options);
          };
        }.bind(this)
      });
      this.loaded = true;
    } else {
      $super(trigger, options);
    }
  },
});

Dropdown.Menu.findOrCreate = function(element) {
  var element = $(element);
  var key = element.identify();
  var menu = Dropdown.Menu.controls[key];
  if (menu == null) menu = Dropdown.Menu.controls[key] = new Dropdown.Menu(element);
  return menu;
}
Dropdown.Menu.controls = {};

Event.observe(window, 'resize', function(event) {
  for (key in Dropdown.Menu.controls) {
    var menu = Dropdown.Menu.controls[key];
    if (menu.visible()) menu.reposition();
  }
});

Event.addBehavior({
  'a.dropdown': Dropdown.TriggerBehavior(),
});