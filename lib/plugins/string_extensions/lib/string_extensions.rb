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
  
  alias_method :to_slug,   :parameterize
  alias_method :slugify,   :parameterize
  alias_method :slugerize, :parameterize
end