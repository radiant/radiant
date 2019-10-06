require 'active_record'

class ActiveRecord::Base
  
  def self.validates_path(*args)
    configuration = args.extract_options!
    validates_each(args, configuration) do |record, attr_name, value|
      page = Page.find_by_path(value)
      record.errors.add(attr_name, :page_not_found, :default => configuration[:message]) if page.nil? || page.is_a?(FileNotFoundPage)
    end
  end
  
  def self.object_id_attr(symbol, klass)
    module_eval %{
      def #{symbol}
        if @#{symbol}.nil? or (@old_#{symbol}_id != #{symbol}_id)
          @old_#{symbol}_id = #{symbol}_id
          klass = #{klass}.descendants.find { |d| d.#{symbol}_name == #{symbol}_id }
          klass ||= #{klass}
          @#{symbol} = klass.new
        else
          @#{symbol}
        end
      end
    }
  end
  
end
