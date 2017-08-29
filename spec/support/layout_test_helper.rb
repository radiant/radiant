module LayoutTestHelper
  
  VALID_LAYOUT_PARAMS = {
    name: 'Layout',
    content: <<-CONTENT
<html>
  <head>
    <title><r:title /></title>
  </head>
  <body>
    <r:content />
  </body>
</html>
    CONTENT
  }
  
  def layout_params(options = {})
    params = VALID_LAYOUT_PARAMS.dup
    params.merge!(options)
  end
end
