class SnippetsScenario < Scenario::Base
  
  def load
    create_snippet "first", :content => "test"
    create_snippet "another", :content => "another test"
    create_snippet "markdown", :filter_id => "Markdown", :content => "**markdown**"
    create_snippet "radius", :content => "<r:title />"
    create_snippet "global_page_cascade", :content => "<r:children:each><r:page:title /> </r:children:each>"
    create_snippet "recursive", :content => "<r:children:each><r:snippet name='recursive' /></r:children:each><r:title />"
  end
  
  helpers do
    def create_snippet(name, attributes={})
      create_record :snippet, name.symbolize, snippet_params(attributes.reverse_merge(:name => name))
    end
    
    def snippet_params(attributes={})
      name = attributes[:name] || unique_snippet_name
      { 
        :name => name,
        :content => "<r:content />"
      }.merge(attributes)
    end
    
    private
    
      @@unique_snippet_name_call_count = 0
      def unique_snippet_name
        @@unique_snippet_name_call_count += 1
        "snippet-#{@@unique_snippet_name_call_count}"
      end
  end
  
end