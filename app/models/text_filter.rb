class TextFilter
  include Simpleton
  include Annotatable
  
  annotate :filter_name, :description
   
  def filter(text)
    text
  end
  
  class << self
    def inherited(subclass)
      subclass.filter_name = subclass.name.to_name('Filter')
    end
    
    def filter(text)
      instance.filter(text)
    end
    
    def description_file(filename)
      text = File.read(filename) rescue ""
      self.description text
    end
  end
end