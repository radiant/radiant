module Dataset
  module Database # :nodoc:
    
    # The interface to a sqlite3 database, this will capture by copying the db
    # file and restore by replacing and reconnecting to one of the same.
    #
    class Sqlite3 < Base
      def initialize(database_spec, storage_path)
        @database_path, @storage_path = database_spec[:database], storage_path
        FileUtils.mkdir_p(@storage_path)
      end
      
      def capture(datasets)
        return if datasets.nil? || datasets.empty?
        cp @database_path, storage_path(datasets)
      end
      
      def restore(datasets)
        store = storage_path(datasets)
        if File.file?(store)
          mv store, @database_path
          ActiveRecord::Base.establish_connection 'test'
          true
        end
      end
      
      def storage_path(datasets)
        "#{@storage_path}/#{datasets.collect {|c| c.__id__}.join('_')}.sqlite3.db"
      end
    end
  end
end