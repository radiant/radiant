class BasicExtension < Radiant::Extension
  version "1.1"
  description "just a test"
  url "http://test.com"
    
  def activate
    tab 'Content' do
      add_item("Basic Extension Tab", "/admin/basic", :before => 'Pages')
    end
  end
end