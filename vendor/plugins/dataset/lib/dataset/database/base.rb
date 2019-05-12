require 'fileutils'

module Dataset
  module Database # :nodoc:
    
    # Provides Dataset a way to clear, dump and load databases.
    class Base
      include FileUtils
      
      def clear
        connection = ActiveRecord::Base.connection
        ActiveRecord::Base.silence do
          connection.tables.each do |table_name|
            connection.delete "DELETE FROM #{connection.quote_table_name(table_name)}",
              "Dataset::Database#clear" unless table_name == ActiveRecord::Migrator.schema_migrations_table_name
          end
        end
      end
      
      def record_meta(record_class)
        record_metas[record_class] ||= Dataset::Record::Meta.new(record_class)
      end
      
      protected
        def record_metas
          @record_metas ||= Hash.new
        end
    end
  end
end