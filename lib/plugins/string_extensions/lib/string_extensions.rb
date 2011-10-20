require 'stringex'

class String
  def symbolize
    self.gsub(/[^A-Za-z0-9]+/, "_").gsub(/(^_+|_+$)/, "").underscore.to_sym
  end
  
  def titlecase
    self.gsub(/((?:^|\s)[a-z])/) { $1.upcase }
  end
  
  def to_name(last_part = '')
    self.underscore.gsub('/', ' ').humanize.titlecase.gsub(/\s*#{last_part}$/, '')
  end

  unless methods.include?('parameterize')
    def parameterize(sep = '-')
      remove_formatting.downcase.replace_whitespace(sep).collapse(sep)
    end
  end
  
  alias :to_slug   :parameterize
  alias :slugify   :parameterize
  alias :slugerize :parameterize
end