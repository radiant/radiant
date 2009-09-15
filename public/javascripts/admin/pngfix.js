/**
 * Correctly handle PNG transparency in Win IE 5.5 & 6.
 * http://homepage.ntlworld.com/bobosola. Updated 18-Jan-2006.
 * 
 * Use in <HEAD> with DEFER keyword wrapped in conditional comments:
 * 
 *   <!--[if lt IE 7]>
 *   <script defer type="text/javascript" src="pngfix.js"></script>
 *   <![endif]-->
 * 
 */

var arVersion = navigator.appVersion.split("MSIE"),
    version = parseFloat(arVersion[1]),
    filters = false;
    
try { filters = !!document.body.filters }
catch (e) {}

if (version >= 5.5 && filters) {
  $A(document.images).each(function(img) {
    if (!img.src.toLowerCase().endsWith('png')) return;
    
    var span = new Element('span', { id: img.id, className: img.className, title: (img.title || img.alt) }).
      setStyle({
        display: 'inline-block',
        width: img.width + 'px',
        height: img.height + 'px',
        filter: 'progid:DXImageTransform.Microsoft.AlphaImageLoader(src="' + img.src + '", sizingMethod="scale")'
      }).
      setStyle(img.style.cssText);
    
    if (img.align == "left")       span.setStyle("float: left");
    else if (img.align == "right") span.setStyle("float: right");
    if (img.parentElement.href)    span.setStyle("cursor: hand");
    
    $(img).replace(span);
  });
}
