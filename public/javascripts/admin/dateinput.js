/*
 * dateinput.js
 * 
 * dependencies: prototype.js, lowpro.js
 * 
 * --------------------------------------------------------------------------
 * 
 * Renders a date input. To use, add the following line to application.js:
 * 
 *   Event.addBehavior({'input.date': DateInputBehavior()});
 * 
 * This will effectively wire all inputs with a class of "date" to the
 * DateInputBehavior.
 * 
 * This code was originally based on Dan Web's code for date_selector.js, but
 * has been modified from its original form. You can find Dan's original
 * code here:
 * 
 * http://github.com/danwrong/low-pro/blob/master/behaviours/date_selector.js
 * 
 * --------------------------------------------------------------------------
 * 
 * Copyright (c) 2007-2009, Five Points Solutions, Inc.
 * Portions Copyright (c) 2004, Dan Web
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

DateInputBehavior = Behavior.create({
  
  initialize: function(options) {
    this.element.setAttribute("autocomplete", "off");
    this.calendar = null;
    this.options = Object.extend(DateInputBehavior.DEFAULTS, options || {});
    this.date = this.getDate();
    this._createCalendar();
  },
  
  setDate: function(value, hideCalendar) {
    this.date = value;
    this.element.value = this.options.setter(this.date);
    var timeoutTime = 250;
    if (Prototype.Browser.IE) timeoutTime = 50;
    
    if (hideCalendar == null) hideCalendar = true;
    
    if (hideCalendar && this.calendar) {
      setTimeout(function() {
        this.calendar.element.hide();
        this.element.select();
      }.bind(this), timeoutTime);
    }
    this.element.fire('date:changed');
  },
  
  _createCalendar : function() {
    var calendar = $div({'class': 'calendar_popup'});
    var body = $(document.getElementsByTagName('body')[0]);
    body.insert(calendar);
    calendar.setStyle('position: absolute');
    this.calendar = new DateInputBehavior.Calendar(calendar, this);
  },
  
  onclick : function(event) {
    if (this._isOverWidget(event)) {
      this.calendar.toggle();
      event.stop();
    }
  },
  
  onmouseover: function(event) {
    if (this._isOverWidget(event)) this.element.setStyle("cursor: pointer");
    else this.element.setStyle("cursor: text");
  },
  
  onmouseout: function(event) {
    if (this._isOverWidget(event)) this.element.setStyle("cursor: text");
    else this.element.setStyle("cursor: pointer");
  },
  
  onmousemove: function(event) {
    this.onmouseover(event);
  },
  
  onkeypress: function(event) {
    switch(event.keyCode) {
      case Event.KEY_UP:
      case 38:
      case Event.KEY_DOWN:
      case 63233:
      case 40:
        this.calendar.toggle();
        event.stop();
        break;
      case Event.KEY_ESC:
        this.calendar.hide();
        break;
      case Event.KEY_TAB:
        this.calendar.hide();
        event.stop();
        var formElements = this.element.up('form').getElements();
        var elementIndex = formElements.indexOf(this.element) + 1;
        if (formElements.length > elementIndex) formElements[elementIndex].focus();
        break;
    }
  },
  
  onkeydown: function(event) {
    if (Prototype.Browser.IE) this.onkeypress(event);
    if (Prototype.Browser.WebKit && (event.keyCode == 40 || event.keyCode == 38)){
      this.onkeypress(event);
    }
  },
  
  getDate : function() {
    return this.options.getter(this.element.value) || new Date;
  },
  
  _isOverWidget: function(event) {
    var positionedOverWidget = null;
    if (Prototype.Browser.IE) {
      var widgetLeft = this.element.cumulativeOffset().left;
      var widgetRight = this.element.cumulativeOffset().left + this.element.getDimensions().width;
      positionedOverWidget = (event.pointerX() >= widgetLeft && event.pointerX() <= widgetRight);
    } else {
      var calendarIconWidth = parseInt(this.element.getStyle('padding-right'));
      var widgetLeft = this.element.cumulativeOffset().left + this.element.getDimensions().width - calendarIconWidth;
      positionedOverWidget = (event.pointerX() >= widgetLeft);
    }
    return positionedOverWidget;
  }
});

DateInputBehavior.Calendar = Behavior.create({
  
  initialize: function(selector) {
    this.selector = selector;
    this.element.hide();
    Event.observe(document, 'click', this.element.hide.bind(this.element));
  },
  
  show: function() {
    DateInputBehavior.Calendar.instances.invoke('hide');
    this.date = this.selector.getDate();
    this.redraw();
    this.element.setStyle({
      'top': this.getVerticalOffset(this.selector.element) + 'px',
      'left': Math.max(this.selector.element.cumulativeOffset().left + this.selector.element.getWidth() - this.element.getWidth() - 4, this.selector.element.cumulativeOffset().left) + 'px',
      'z-index': 10001
    });
    this.element.show();
    this.active = true;
  },
  
  getVerticalOffset: function(selector){
    var defaultOffset = this.selector.element.cumulativeOffset().top + this.selector.element.getHeight() + 2;
    var height = this.element.getHeight();
    var top = 0;
    
    if(document.viewport.getHeight() > defaultOffset + height) {
      top = defaultOffset;
    } else {
      top = (defaultOffset - height - selector.getHeight() - 6);
    }
    
    if (top < document.viewport.getScrollOffsets().top)
      top = document.viewport.getScrollOffsets().top;
    
    return top;
  },
  
  hide: function() {
    this.element.hide();
    this.active = false;
  },
  
  toggle: function() {
    if (this.element.visible()) {
      this.hide();
    } else {
      this.show()
    }
  },
  
  redraw: function() {
    var oldMonth = this.element.down('select.month');
    if (oldMonth) Event.stopObserving(oldMonth, 'change', oldMonth._monthChanged);
    
    var oldYear = this.element.down('select.year');
    if (oldYear) Event.stopObserving(oldYear, 'change', oldYear._yearChanged);
    
    var html = '<table class="calendar" border="0" cellpadding="0" cellspacing="0">' +
               '  <thead>' +
               '    <tr class="month_year_navigation">' + 
               '      <th class="back"><a href="#">&larr;</a></th>' +
               '      <th colspan="5" class="month_year">' + this._monthYear() + '</th>' +
               '      <th class="forward"><a href="#">&rarr;</a></th>' +
               '    </tr>' +
               '    <tr class="day_header">' + this._dayRows() + '</tr>' +
               '  </thead>' +
               '  <tbody>' +
               this._buildDateCells() +
               '</tbody></table>';
    this.element.innerHTML = '';
    var table = DOM.Builder.fromHTML(html);
    this.element.insert(table);
    
    var newMonth = this.element.down('select.month');
    newMonth._monthChanged = this._monthChanged.bindAsEventListener(this);
    Event.observe(newMonth, 'change', newMonth._monthChanged);
    
    var newYear = this.element.down('select.year');
    newYear._yearChanged = this._yearChanged.bindAsEventListener(this);
    Event.observe(newYear, 'change', newYear._yearChanged);
  },
  
  onclick: function(event) {
    event.stop();
    if ($(event.target.parentNode).hasClassName('day')) return this._setDate(event.target);
    if ($(event.target.parentNode).hasClassName('back')) return this._backMonth();
    if ($(event.target.parentNode).hasClassName('forward')) return this._forwardMonth();
  },
  
  _monthChanged: function(event) {
    event.stop();
    return this._selectMonth(event.target);
  },
  
  _yearChanged: function(event) {
    event.stop();
    return this._selectYear(event.target);
  },
  
  _setDate: function(source) {
    if (source.innerHTML.strip() != '') {
      this.date.setDate(parseInt(source.innerHTML));
      this.selector.setDate(this.date);
      $A(this.element.getElementsByClassName('selected')).invoke('removeClassName', 'selected');
      source.parentNode.addClassName('selected');
    }
  },
  
  _backMonth: function() {
    this.date.setMonth(this.date.getMonth() - 1);
    this.redraw();
    return false;
  },
  
  _forwardMonth: function() {
    this.date.setMonth(this.date.getMonth() + 1);
    this.redraw();
    return false;
  },
  
  _selectMonth: function(combo) {
    this.date.setMonth(combo.selectedIndex);
    this.selector.setDate(this.date, false);
    this.redraw();
    return false;
  },
  
  _selectYear: function(combo) {
    var year = parseInt($F(combo))
    this.date.setYear(year);
    this.selector.setDate(this.date, false);
    this.redraw();
    return false;
  },
  
  _getDateFromSelector: function() {
    this.date = new Date(this.selector.date.getTime());
  },
  
  _firstDay: function(month, year) {
    return new Date(year, month, 1).getDay();
  },
  
  _monthLength: function(month, year) {
    var length = DateInputBehavior.Calendar.MONTHS[month].days;
    return (month == 1 && (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0))) ? 29 : length;
  },
  
  _monthYear: function() {
    var currentMonth = this.date.getMonth();
    var currentYear = this.date.getFullYear();
    var todaysYear = (new Date()).getFullYear();
    var html = '';
    html += '<select class="month">';
    DateInputBehavior.Calendar.MONTHS.each(function(month, index) {
      if (index == currentMonth)  {
        html += '<option selected="selected">' + month.label + '</option>';
      } else {
        html += '<option>' + month.label + '</option>';
      }
    });
    html += '</select>';
    if (!(Prototype.Browser.WebKit || Prototype.Browser.MobileSafari)) html += ' ';
    html += '<select class="year">';
    for (var index = todaysYear - 100; index < todaysYear + 50; index++) {
      if (index == currentYear) {
        html += '<option selected="selected">' + index + '</option>';
      } else {
        html += '<option>' + index + '</option>';
      }
    }
    html += '</select>';
    return html;
  },
  
  _dayRows: function() {
    for (var i = 0, html='', day; day = DateInputBehavior.Calendar.DAYS[i]; i++)
      html += '<th>' + day + '</th>';
    return html;
  },
  
  _buildDateCells: function() {
    var month = this.date.getMonth(), year = this.date.getFullYear();
    var day = 1, monthLength = this._monthLength(month, year), firstDay = this._firstDay(month, year);
    var html = '<tr>';
    
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j <= 6; j++) {
        
        if (day <= monthLength && (i > 0 || j >= firstDay)) { 
          var classes = ['day'];
          
          if (this._compareDate(new Date, year, month, day)) classes.push('today');
          if (this._compareDate(this.selector.date, year, month, day)) classes.push('selected');
          
          html += '<td class="' + classes.join(' ') + '">' + 
                  '<a href="#">' + day++ + '</a>' + 
                  '</td>';
        } else html += '<td></td>';
      }
      
      if (day > monthLength) break;
      else html += '</tr><tr>';
    }
    
    return html + '</tr>';
  },
  
  _compareDate: function(date, year, month, day) {
    return date.getFullYear() == year &&
           date.getMonth() == month &&
           date.getDate() == day;
  }
});

DateInputBehavior.DEFAULTS = {
  
  setter: function(date) {
    return  DateInputBehavior.Calendar.MONTHS[date.getMonth()].label +
      ' ' + date.getDate() + ', ' + date.getFullYear();
  },
  
  getter: function(value) {
    var parsed = Date.parse(value);
    
    if (!isNaN(parsed)) return new Date(parsed);
    else return null;
  }
  
};

Object.extend(DateInputBehavior.Calendar, {
  
  DAYS : $w('S M T W T F S'),
  
  MONTHS : [
    { label: 'January',   days: 31 },
    { label: 'February',  days: 28 },
    { label: 'March',     days: 31 },
    { label: 'April',     days: 30 },
    { label: 'May',       days: 31 },
    { label: 'June',      days: 30 },
    { label: 'July',      days: 31 },
    { label: 'August',    days: 31 },
    { label: 'September', days: 30 },
    { label: 'October',   days: 31 },
    { label: 'November',  days: 30 },
    { label: 'December',  days: 31 }
  ]
  
});