/*
  cookie.js
  
  Copyright (c) 2007, 2008 Maxime Haineault
  (http://www.haineault.com/code/cookie-js/, http://code.google.com/p/cookie-js/)
  
  Portions Copyright (c) 2008, John W. Long
  
  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:
  
  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

Cookie = {  
  get: function(name) {
    // Still not sure that "[a-zA-Z0-9.()=|%/]+($|;)" match *all* allowed characters in cookies
    tmp =  document.cookie.match((new RegExp(name +'=[a-zA-Z0-9.()=|%/]+($|;)','g')));
    if (!tmp || !tmp[0]) {
      return null;
    } else {
      return unescape(tmp[0].substring(name.length + 1, tmp[0].length).replace(';', '')) || null;
    }
  },  
  
  set: function(name, value, expireInHours, path, domain, secure) {
    var cookie = [
      name + '=' + escape(value),
      'path=' + ((!path || path == '')  ? '/' : path)
    ];
    if (Cookie._notEmpty(domain)) cookie.push('domain=' + domain);
    if (Cookie._notEmpty(expireInHours)) cookie.push(Cookie._hoursToExpireDate(expireInHours));
    if (Cookie._notEmpty(secure)) cookie.push('secure');
    return document.cookie = cookie.join(';');
  },
  
  erase: function(name, path, domain) {
    path = (!path || typeof path != 'string') ? '' : path;
    domain = (!domain || typeof domain != 'string') ? '' : domain;
    if (Cookie.get(name)) Cookie.set(name, '', 'Thu, 01-Jan-70 00:00:01 GMT', path, domain);
  },
  
  // Returns true if cookies are enabled
  accept: function() {
    Cookie.set('b49f729efde9b2578ea9f00563d06e57', 'true');
    if (Cookie.get('b49f729efde9b2578ea9f00563d06e57') == 'true') {
      Cookie.unset('b49f729efde9b2578ea9f00563d06e57');
      return true;
    }
    return false;
  },
  
  _notEmpty: function(value) {
    return (typeof value != 'undefined' && value != null && value != '');
  },
  
  // Private function for calculating the date of expiration based on hours
  _hoursToExpireDate: function(hours) {
    if (parseInt(hours) == 'NaN' ) return '';
    else {
      now = new Date();
      now.setTime(now.getTime() + (parseInt(hours) * 60 * 60 * 1000));
      return now.toGMTString();     
    }
  }
}