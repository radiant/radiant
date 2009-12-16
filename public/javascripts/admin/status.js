/*
 *  status.js
 *
 *  dependencies: prototype.js, effects.js, lowpro.js
 *  
 *  --------------------------------------------------------------------------
 *  
 *  Allows you to display a status message when submiting a form. To use,
 *  simply add the following to application.js:
 *  
 *    Event.addBehavior({'form': Status.FormBehavior()});
 *  
 *  And then add an "data-onsubmit_status" to each form that you want to display
 *  a status message on submit for:
 *  
 *    <form data-onsubmit_status="Saving changes" ...>
 *  
 *  Based on code from popup.js.
 *  
 *  --------------------------------------------------------------------------
 *  
 *  Copyright (c) 2008, John W. Long
 *  Portions copyright (c) 2008, Five Points Solutions, Inc.
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
if(typeof(relative_url_root) === 'undefined'){var relative_url_root = '';}
var Status = {
  CornerThickness: 12,
  SpinnerImage: relative_url_root+'/images/admin/status_spinner.gif',
  SpinnerImageWidth: 32,
  SpinnerImageHeight: 33,
  BackgroundImage: relative_url_root+'/images/admin/status_background.png',
  TopLeftImage: relative_url_root+'/images/admin/status_top_left.png',
  TopRightImage: relative_url_root+'/images/admin/status_top_right.png',
  BottomLeftImage: relative_url_root+'/images/admin/status_bottom_left.png',
  BottomRightImage: relative_url_root+'/images/admin/status_bottom_right.png'
};

Status.BackgroundImages = function() {
  return $A([
    Status.SpinnerImage,
    Status.BackgroundImage,
    Status.TopLeftImage,
    Status.TopRightImage,
    Status.BottomLeftImage,
    Status.BottomRightImage
  ]);
}

Status.preloadImages = function() {
  if (!Status.imagesPreloaded) {
    Status.BackgroundImages().each(function(src) {
      var image = new Image();
      image.src = src;
    });
    Status.preloadedImages = true;
  }
}

Status.FormBehavior = Behavior.create({
  initialize: function() {
    var attr = this.element.attributes['data-onsubmit_status']
    if (attr) this.status = attr.value; 
    if (this.status) this.element.observe('submit', function() { showStatus(this.status) }.bind(this));
  }
});

Status.Window = Class.create({
  initialize: function() {
    Status.preloadImages();
    this.buildWindow();
  },

  buildWindow: function() {
    this.element = $div({'class': 'status_window', style: 'display: none; padding: 0 ' + Status.CornerThickness + 'px; position: absolute'});
    
    this.top = $div({style: 'background: url(' + Status.BackgroundImage + '); height: ' + Status.CornerThickness + 'px'});
    this.element.insert(this.top);
    
    var outer = $div({style: 'background: url(' + Status.BackgroundImage + '); margin: 0px -' + Status.CornerThickness + 'px; padding: 0px ' + Status.CornerThickness + 'px; position: relative'});
    this.element.insert(outer);
    
    this.bottom = $div({style: 'background: url(' + Status.BackgroundImage + '); height: ' + Status.CornerThickness + 'px'});
    this.element.insert(this.bottom);
    
    var topLeft = $div({style: 'background: url(' + Status.TopLeftImage + '); height: ' + Status.CornerThickness + 'px; width: ' + Status.CornerThickness + 'px; position: absolute; left: 0; top: -' + Status.CornerThickness + 'px'});
    outer.insert(topLeft);
    
    var topRight = $div({style: 'background: url(' + Status.TopRightImage + '); height: ' + Status.CornerThickness + 'px; width: ' + Status.CornerThickness + 'px; position: absolute; right: 0; top: -' + Status.CornerThickness + 'px'});
    outer.insert(topRight);
    
    var bottomLeft = $div({style: 'background: url(' + Status.BottomLeftImage + '); height: ' + Status.CornerThickness + 'px; width: ' + Status.CornerThickness + 'px; position: absolute; left: 0; bottom: -' + Status.CornerThickness + 'px'});
    outer.insert(bottomLeft);
    
    var bottomRight = $div({style: 'background: url(' + Status.BottomRightImage + '); height: ' + Status.CornerThickness + 'px; width: ' + Status.CornerThickness + 'px; position: absolute; right: 0; bottom: -' + Status.CornerThickness + 'px'});
    outer.insert(bottomRight);
    
    this.content = $div({'class': 'status_content'});
    outer.insert(this.content);
    
    this.spinner = $img({src: Status.SpinnerImage, width: Status.SpinnerImageWidth, height: Status.SpinnerImageHeight, alt: ''});
    this.status = $div()
    
    var table = $table(
      $tr(
        $td(this.spinner),
        $td({style: 'padding-left: ' + Status.CornerThickness + 'px'}, this.status)
      )
    );
    this.content.insert(table);
    
    var body = $$('body').first();
    body.insert(this.element);
  },
  
  setStatus: function(value) {
    this.status.update(value)
  },
  
  getStatus: function() {
    return this.status.innerHTML();
  },
  
  show: function(options) {
    if (Prototype.Browser.IE) {
      // IE fixes
      var width = this.element.getWidth() - (Status.CornerThickness * 2);
      this.top.setStyle("width:" + width + "px");
      this.bottom.setStyle("width:" + width + "px");
    }
    this.centerWindowInView();
    this.element.show();
  },
  
  hide: function() {
    this.element.hide();
  },
  
  toggle: function() {
    if (this.visible()) {
      this.hide();
    } else {
      this.show();
    }
  },
  
  visible: function() {
    return this.element.visible();
  },
  
  centerWindowInView: function() {
    var offsets = document.viewport.getScrollOffsets();
    this.element.setStyle({
      left: parseInt(offsets.left + (document.viewport.getWidth() - this.element.getWidth()) / 2) + 'px',
      top: parseInt(offsets.top + (document.viewport.getHeight() - this.element.getHeight()) / 2.2) + 'px'
    });
  }
});

// Setup the modal status window onload
Event.observe(window, 'load', function() {
  Status.window = new Status.Window();
});

// Sets the status to string
function setStatus(string) {
  Status.window.setStatus(string);
  if (Status.window.visible()) Status.window.centerWindowInView();
}

// Sets the status to string and shows the modal status window
function showStatus(string) {
  setStatus(string);
  Status.window.show();
}

// Hides the modal status window
function hideStatus() {
  Status.window.hide();
}