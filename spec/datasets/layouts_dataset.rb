class LayoutsDataset < Dataset::Base

  def load
    create_layout "Main", :content => <<-CONTENT
<html>
  <head>
    <title><r:title /></title>
  </head>
  <body>
    <r:content />
  </body>
</html>
    CONTENT

    create_layout "UTF8", :content_type => "text/html;charset=utf8", :content => <<-CONTENT
<html>
  <head>
    <title><r:title /></title>
  </head>
  <body>
    <r:content />
  </body>
</html>
    CONTENT
  end

  helpers do
    def create_layout(name, attributes={})
      create_record :layout, name.symbolize, layout_params(attributes.reverse_merge(:name => name))
    end

    def layout_params(attributes={})
      name = attributes[:name] || unique_layout_name
      {
        :name => name,
        :content => "<r:content />"
      }.merge(attributes)
    end

    def destroy_test_layout(name = @layout_name)
      while layout = get_test_layout(name) do
        layout.destroy
      end
    end

    def get_test_layout(name = @layout_name)
      Layout.find_by_name(name)
    end

    private

      @@unique_layout_name_call_count = 0
      def unique_layout_name
        @@unique_layout_name_call_count += 1
        "Layout #{@@unique_layout_name_call_count}"
      end
  end
end