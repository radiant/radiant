class Radiant::AdminUI::RegionSet

  def initialize
    @regions = Hash.new do |h,k|
      h[k] = []
    end
    yield self if block_given?
  end
  
  def [](region)
    @regions[region.to_sym]
  end
  
  def add(region=nil, partial=nil, options={})
    raise ArgumentError, "You must specify a region and a partial" unless region and partial
    if options[:before]
      index = @regions[region].empty? ? 0 : (@regions[region].index(options[:before]) || @regions[region].size)
      self[region].insert(index, partial)
    elsif options[:after]
      index = @regions[region].empty? ? 0 : (@regions[region].index(options[:after]) || @regions[region].size - 1)
      self[region].insert(index + 1, partial)
    else
      self[region] << partial
    end
  end
  
  def method_missing(method, *args, &block)
    if args.empty?
      self[method]
    else
      super
    end
  end
  
end