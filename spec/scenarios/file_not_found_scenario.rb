class CustomFileNotFoundPage < FileNotFoundPage
end

class FileNotFoundScenario < Scenario::Base
  uses :home_page
  
  def load
    create_page "File Not Found", :slug => "missing", :class_name => "FileNotFoundPage"
    create_page "Gallery" do
      create_page "No Picture", :class_name => "CustomFileNotFoundPage"
    end 
  end
end