/*
 * status.js
 * 
 * dependencies: prototype.js, effects.js, lowpro.js
 * 
 * --------------------------------------------------------------------------
 * 
 * Allows you to display a status message when submiting a form. To use,
 * simply add the "data-onsubmit_status" attribute to a form:
 * 
 *   <form data-onsubmit_status="Saving changes" ...>
 * 
 * For more information, see:
 * 
 *   http://wiseheartdesign.com/articles/2009/12/16/statusjs-work-well-with-messages/
 * 
 * Some code taken from popup.js.
 *
 * --------------------------------------------------------------------------
 * 
 * Copyright (c) 2008-2009, John W. Long
 * Portions copyright (c) 2008, Five Points Solutions, Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 */

var Status = {
  CornerThickness: 12,
  SpinnerImage: '/images/status_spinner.gif',
  SpinnerImageWidth: 32,
  SpinnerImageHeight: 33,
  BackgroundImage: '/images/status_background.png',
  TopLeftImage: '/images/status_top_left.png',
  TopRightImage: '/images/status_top_right.png',
  BottomLeftImage: '/images/status_bottom_left.png',
  BottomRightImage: '/images/status_bottom_right.png',
  MessageFontFamily: '"Trebuchet MS", Verdana, Arial, Helvetica, sans-serif',
  MessageFontSize: '14px',
  MessageColor: '#e5e5e5',
  Modal: false,
  ModalOverlayColor: 'white',
  ModalOverlayOpacity: 0.4
};

Status.window = function() {
  if (!this.statusWindow) this.statusWindow = new Status.Window();
  return this.statusWindow;
};

// Sets the status to string and shows the status window. If modal is passed
// as true a white transparent div that covers the entire page is positioned
// under the status window causing a diming effect and preventing stray mouse
// clicks.
Status.show = function(string, modal) {
  Status.window().setStatus(string);
  Status.window().show(modal);
};

// Hides the status window
Status.hide = function() {
  Status.window().hide();
};

document.on('submit', 'form[data-onsubmit_status]', function(e, form) {
  Status.show(form.readAttribute('data-onsubmit_status'));
});

document.on('click', 'a[data-onclick_status]', function(e, link) {
  Status.show(link.readAttribute('data-onclick_status'));
});

Status.BackgroundImages = function() {
  return $A([
    Status.SpinnerImage,
    Status.BackgroundImage,
    Status.TopLeftImage,
    Status.TopRightImage,
    Status.BottomLeftImage,
    Status.BottomRightImage
  ]);
};

Status.preloadImages = function() {
  if (!Status.imagesPreloaded) {
    Status.BackgroundImages().each(function(src) {
      var image = new Image();
      image.src = src;
    });
    Status.preloadedImages = true;
  }
};

document.on('dom:loaded', function() {
  Status.preloadImages();
});

Status.Window = Class.create({
  initialize: function() {
    Status.preloadImages();
    this.buildWindow();
  },
  
  buildWindow: function() {
    this.element = $table({'class': 'status_window', style: 'display: none; position: absolute; border-collapse: collapse; padding: 0px; margin: 0px; z-index: 10000'});
    var tbody = $tbody();
    this.element.insert(tbody);
    
    var top_row = $tr();
    top_row.insert($td({style: 'background: url(' + Status.TopLeftImage + '); height: ' + Status.CornerThickness + 'px; width: ' + Status.CornerThickness + 'px; padding: 0px'}));
    top_row.insert($td({style: 'background: url(' + Status.BackgroundImage + '); height: ' + Status.CornerThickness + 'px; padding: 0px'}));
    top_row.insert($td({style: 'background: url(' + Status.TopRightImage + '); height: ' + Status.CornerThickness + 'px; width: ' + Status.CornerThickness + 'px; padding: 0px'}));
    tbody.insert(top_row);
    
    var content_row = $tr();
    content_row.insert($td({style: 'background: url(' + Status.BackgroundImage + '); width: ' + Status.CornerThickness + 'px; padding: 0px'}, ''));
    this.content = $td({'class': 'status_content', style: 'background: url(' + Status.BackgroundImage + '); padding: 0px ' + Status.CornerThickness + 'px'});
    content_row.insert(this.content);
    content_row.insert($td({style: 'background: url(' + Status.BackgroundImage + '); width: ' + Status.CornerThickness + 'px; padding: 0px'}, ''));
    tbody.insert(content_row);
    
    var bottom_row = $tr();
    bottom_row.insert($td({style: 'background: url(' + Status.BottomLeftImage + '); height: ' + Status.CornerThickness + 'px; width: ' + Status.CornerThickness + 'px; padding: 0px'}));
    bottom_row.insert($td({style: 'background: url(' + Status.BackgroundImage + '); height: ' + Status.CornerThickness + 'px; padding: 0px'}));
    bottom_row.insert($td({style: 'background: url(' + Status.BottomRightImage + '); height: ' + Status.CornerThickness + 'px; width: ' + Status.CornerThickness + 'px; padding: 0px'}));
    tbody.insert(bottom_row);
    
    this.spinner = $img({src: Status.SpinnerImage, width: Status.SpinnerImageWidth, height: Status.SpinnerImageHeight, alt: ''});
    this.status = $div({'class': 'status_message', style: 'color: ' + Status.MessageColor + '; font-family: ' + Status.MessageFontFamily + '; font-size: ' + Status.MessageFontSize});
    
    var table = $table({border: 0, cellpadding: 0, cellspacing: 0, style: 'table-layout: auto'},
      $tbody(
        $tr(
          $td({style: 'width: ' + Status.SpinnerImageWidth + 'px'}, this.spinner),
          $td({style: 'padding-left: ' + Status.CornerThickness + 'px'}, this.status)
        )
      )
    );
    this.content.insert(table);
    
    var body = $$('body').first();
    body.insert(this.element);
  },
  
  setStatus: function(value) {
    this.status.update(value);
  },
  
  getStatus: function() {
    return this.status.innerHTML();
  },
  
  show: function(modal) {
    if (modal || Status.Modal) this._showModalOverlay();
    this.element.show();
    this.centerWindowInView();
  },
  
  hide: function() {
    this._hideModalOverlay();
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
      left: parseInt(offsets.left + (document.viewport.getWidth() - this.element.getWidth()) / 2, 10) + 'px',
      top: parseInt(offsets.top + (document.viewport.getHeight() - this.element.getHeight()) / 2.2, 10) + 'px'
    });
  },
  
  _showModalOverlay: function() {
    if (!this.overlay) {
      this.overlay = $div({style: 'position: absolute; background-color: ' + Status.ModalOverlayColor + '; top: 0px; left: 0px; z-index: 100;'});
      this.overlay.setStyle('position: fixed');
      this.overlay.setOpacity(Status.ModalOverlayOpacity);
      document.body.insert(this.overlay);
    }
    this.overlay.setStyle('height: ' + document.viewport.getHeight() + 'px; width: ' + document.viewport.getWidth() + 'px;');
    this.overlay.show();
  },
  
  _hideModalOverlay: function() {
    if (this.overlay) this.overlay.hide();
  }
});
