FactoryGirl.define do
  
  factory :layout do
    name 'Main Layout'
    content <<-CONTENT
<html>
  <head>
    <title><r:title /></title>
  </head>
  <body>
    <r:content />
  </body>
</html>
    CONTENT
    
    factory :utf8_layout do
      name 'utf8'
      content_type "text/html;charset=utf8"
    end
    
  end
  
end