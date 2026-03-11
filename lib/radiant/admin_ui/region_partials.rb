class Radiant::AdminUI::RegionPartials
  def initialize(template)
    @partials = Hash.new {|h,k| h[k] = "<strong>`#{k}' default partial not found!</strong>" }
    @template = template
  end
  
  def [](key)
    @partials[key.to_s]
  end
  
  def method_missing(method, *args, &block)
    if block_given?
      @partials[method.to_s] = @template.capture(&block)
    else
      @partials[method.to_s]
    end
  end
end