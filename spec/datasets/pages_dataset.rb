class VirtualPage < Page
  def virtual?
    true
  end
end

class PagesDataset < Dataset::Base
  uses :home_page
  
  def load
    create_page "First"
    create_page "Another"
    create_page "Radius", :body => "<r:title />"
    create_page "Parent" do
      create_page "Child" do
        create_page "Grandchild" do
          create_page "Great Grandchild"
        end
      end
      create_page "Child 2"
      create_page "Child 3"
    end
    create_page "Childless"
    create_page "Assorted", :keywords => "sweet & harmonious biscuits", :description => "sweet & harmonious biscuits" do
      breadcrumbs = %w(f e d c b a j i h g)
      %w(a b c d e f g h i j).each_with_index do |name, i|
        create_page name, :breadcrumb => breadcrumbs[i], :published_at => Time.now - (10 - i).minutes
      end
      create_page "Assorted Draft", :status_id => Status[:draft].id, :slug => "draft"
      create_page "Assorted Virtual", :class_name => "VirtualPage", :virtual => true, :slug => "virtual"
    end
    create_page "News" do
      create_page "Article",   :published_at => DateTime.parse('2000-12-01 08:41:07')
      create_page "Article 2", :published_at => DateTime.parse('2001-02-09 08:42:04')
      create_page "Article 3", :published_at => DateTime.parse('2001-02-24 12:02:43')
      create_page "Article 4", :published_at => DateTime.parse('2001-03-06 03:32:31')
      create_page "Draft Article",:status_id => Status[:draft].id
    end
    create_page "Draft", :status_id => Status[:draft].id
    create_page "Hidden", :status_id => Status[:hidden].id
    date = Time.utc(2006, 1, 11)
    create_page "Dated", :published_at => date, :created_at => (date - 1.day), :updated_at => (date + 1.day)

    create_page "Devtags" do
      create_page_part "if_dev", :content => "<r:if_dev>dev</r:if_dev>"
      create_page_part "unless_dev", :content => "<r:unless_dev>not dev</r:unless_dev>"
    end
    create_page "Virtual", :class_name => "VirtualPage", :virtual => true
    create_page "Party" do
      create_page_part "favors"
      create_page_part "games"
      create_page "Guests"
    end
    create_page "Recursive parts" do
      create_page_part "recursive_body", :name => "body", :content => "<r:content />"
      create_page_part "recursive_one", :name => "one", :content => '<r:content part="two" />'
      create_page_part "recursive_two", :name => "two", :content => '<r:content part="one" />'
      create_page_part "repetitive_part", :name => "repeat",
        :content => '<r:content part="beat"/><r:content part="beat"/>'
      create_page_part "repeated_part", :name => "beat", :content => 'x'
    end
  end
  
end
