require 'file_not_found_page'

unless defined?(::CustomFileNotFoundPage)
  class ::CustomFileNotFoundPage < FileNotFoundPage
  end
end

class FileNotFoundDataset < Dataset::Base
  uses :home_page
  
  def load
    create_page "Draft File Not Found", :class_name => "FileNotFoundPage", :status_id => Status[:draft].id
    create_page "File Not Found", :slug => "missing", :class_name => "FileNotFoundPage"
    create_page "Gallery" do
      create_page "Draft No Picture", :class_name => "CustomFileNotFoundPage", :status_id => Status[:draft].id
      create_page "No Picture", :class_name => "CustomFileNotFoundPage"
    end 
    create_page "Drafts" do
      create_page "Lonely Draft File Not Found", :class_name => "FileNotFoundPage", :status_id => Status[:draft].id
    end
  end
end