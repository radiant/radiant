module Dataset
  module Database # :nodoc:
    
    # The interface to a mySQL database, this will capture by creating a dump
    # file and restore by loading one of the same.
    #
    class Mysql < Base
      def initialize(database_spec, storage_path)
        @database = database_spec[:database]
        @username = database_spec[:username]
        @password = database_spec[:password]
        @storage_path = storage_path
        FileUtils.mkdir_p(@storage_path)
      end
      
      def capture(datasets)
        return if datasets.nil? || datasets.empty?
        `mysqldump -u #{@username} --password=#{@password} --compact --extended-insert --no-create-db --add-drop-table --quick --quote-names #{@database} > #{storage_path(datasets)}`
      end
      
      def restore(datasets)
        store = storage_path(datasets)
        if File.file?(store)
          `mysql -u #{@username} --password=#{@password} --database=#{@database} < #{store}`
          true
        end
      end
      
      def storage_path(datasets)
        "#{@storage_path}/#{datasets.collect {|c| c.__id__}.join('_')}.sql"
      end
    end
  end
end