require 'rbconfig'

class InstanceGenerator < Rails::Generator::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])
  
  DATABASES = %w( mysql postgresql sqlite3 sqlserver db2 )
  
  MYSQL_SOCKET_LOCATIONS = [
    "/tmp/mysql.sock",                        # default
    "/var/run/mysqld/mysqld.sock",            # debian/gentoo
    "/var/tmp/mysql.sock",                    # freebsd
    "/var/lib/mysql/mysql.sock",              # fedora
    "/opt/local/lib/mysql/mysql.sock",        # fedora
    "/opt/local/var/run/mysqld/mysqld.sock",  # mac + darwinports + mysql
    "/opt/local/var/run/mysql4/mysqld.sock",  # mac + darwinports + mysql4
    "/opt/local/var/run/mysql5/mysqld.sock"   # mac + darwinports + mysql5
  ]
    
  default_options :db => "sqlite3", :shebang => DEFAULT_SHEBANG, :freeze => false

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    usage("Databases supported for preconfiguration are: #{DATABASES.join(", ")}") if (options[:db] && !DATABASES.include?(options[:db]))
    @destination_root = args.shift
  end

  def manifest
    # The absolute location of the Radiant files
    root = File.expand_path(RADIANT_ROOT) 
    
    # Use /usr/bin/env if no special shebang was specified
    script_options     = { :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang] }
    dispatcher_options = { :chmod => 0755, :shebang => options[:shebang] }
    
    record do |m|
      # Root directory
      m.directory ""
      
      # Standard files and directories
      base_dirs = %w(config config/environments config/initializers db log script public vendor/plugins vendor/extensions)
      text_files = %w(CHANGELOG.md CONTRIBUTORS.md LICENSE.md INSTALL.md README.md)
      environments = Dir["#{root}/config/environments/*.rb"]
      bundler_compatibility_files = %w{config/preinitializer.rb}
      schema_file = %w{db/schema.rb}
      scripts = Dir["#{root}/script/**/*"].reject { |f| f =~ /(destroy|generate|plugin)$/ }
      public_files = ["public/.htaccess"] + Dir["#{root}/public/**/*"]
      
      files = base_dirs + text_files + environments + bundler_compatibility_files + schema_file + scripts + public_files
      files.map! { |f| f = $1 if f =~ %r{^#{root}/(.+)$}; f }
      files.sort!
      
      files.each do |file|
        case
        when File.directory?("#{root}/#{file}")
          m.directory file
        when file =~ %r{^script/}
          m.file radiant_root(file), file, script_options
        when file =~ %r{^public/dispatch}
          m.file radiant_root(file), file, dispatcher_options
        else
          m.file radiant_root(file), file
        end
      end
      
      # script/generate
      m.file "instance_generate", "script/generate", script_options
      
      # database.yml and .htaccess
      m.template "databases/#{options[:db]}.yml", "config/database.yml", :assigns => {
        :app_name => File.basename(File.expand_path(@destination_root)),
        :socket   => options[:db] == "mysql" ? mysql_socket_location : nil
      }

      # Instance Gemfile
      m.template "instance_gemfile", "Gemfile", :assigns => {
        :radiant_version => Radiant::Version.to_s,
        :sqlite_version  => Gem.loaded_specs['sqlite3'].version.to_s,
        :db => options[:db]
      }

      # Instance Rakefile
      m.file "instance_rakefile", "Rakefile"

      # Config.ru is useful in rack-based situations like Pow
      m.file "instance_config.ru", "config.ru"

      # Instance Configurations
      m.file "instance_routes.rb", "config/routes.rb"
      m.template "instance_environment.rb", "config/environment.rb", :assigns => {
        :radiant_environment => File.join(File.dirname(__FILE__), 'templates', radiant_root("config/environment.rb")),
        :app_name => File.basename(File.expand_path(@destination_root))
      }
      m.template "instance_boot.rb", "config/boot.rb"
      m.file "instance_radiant_config.rb", "config/initializers/radiant_config.rb"
      
      m.readme radiant_root("INSTALL.md")
    end
  end

  protected

    def banner
      "Usage: #{$0} /path/to/radiant/app [options]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("-r", "--ruby=path", String,
             "Path to the Ruby binary of your choice (otherwise scripts use env, dispatchers current path).",
             "Default: #{DEFAULT_SHEBANG}") { |v| options[:shebang] = v }
      opt.on("-d", "--database=name", String,
            "Preconfigure for selected database (options: #{DATABASES.join(", ")}).",
            "Default: sqlite3") { |v| options[:db] = v }
    end
    
    def mysql_socket_location
      RUBY_PLATFORM =~ /mswin32/ ? MYSQL_SOCKET_LOCATIONS.find { |f| File.exists?(f) } : nil
    end

  private

    def radiant_root(filename = '')
      File.join("..", "..", "..", "..", filename)
    end
  
end
