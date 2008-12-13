require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::Exporter do
  dataset :pages_with_layouts, :users_and_pages, :snippets

  before :each do
    @exporter = Radiant::Exporter
    @output = @exporter.export
    @hash = YAML::load(@output)
    @classes  = ['Radiant::Configs', 'Users', 'Pages', 'PageParts', 'Snippets', 'Layouts']
  end
  
  it "should output a string" do
    @output.should be_kind_of(String)
  end
  
  it "should output all Radiant models" do
    @classes.all? { |c| @hash.has_key?(c) }.should be_true
  end
  
  it "should output the models by id as hashes" do
    @hash['Pages'][page_id(:home)]['title'].should == pages(:home).title
    @hash['Users'][user_id(:admin)]['name'].should == users(:admin).name
  end
end