class ArchiveFinder
  
  def initialize(&block)
    @block = block
  end
  
  def find(method, options = {})
    @block.call(method, options)
  end
  
  class << self
    def year_finder(finder, year)
      new do |method, options|
        start = Time.local(year)
        finish = start.next_year
        add_condition(options, "published_at >= ? and published_at < ?", start, finish)
        finder.find(method, options)
      end
    end
    
    def month_finder(finder, year, month)
      new do |method, options|
        start = Time.local(year, month)
        finish = start.next_month
        add_condition(options, "published_at >= ? and published_at < ?", start, finish)
        finder.find(method, options)
      end
    end
    
    def day_finder(finder, year, month, day)
      new do |method, options|
        start = Time.local(year, month, day)
        finish = start.tomorrow
        add_condition(options, "published_at >= ? and published_at < ?", start, finish)
        finder.find(method, options)
      end
    end
    
    private
      
      def concat_conditions(a, b)
        sql = "(#{ [a.shift, b.shift].compact.join(") AND (") })"
        params = a + b
        [sql, *params]
      end
      
      def add_condition(options, *condition)
        old = options[:conditions] || []
        conditions = concat_conditions(old, condition)
        options[:conditions] = conditions
        options
      end
      
  end
end
