raise "To avoid rake task loading problems: run 'rake clobber' in vendor/plugins/rspec" if File.directory?(File.join(File.dirname(__FILE__), *%w[.. .. vendor plugins rspec pkg]))
raise "To avoid rake task loading problems: run 'rake clobber' in vendor/plugins/rspec-rails" if File.directory?(File.join(File.dirname(__FILE__), *%w[.. .. vendor plugins rspec-rails pkg]))

# In rails 1.2, plugins aren't available in the path until they're loaded.
# Check to see if the rspec plugin is installed first and require
# it if it is.  If not, use the gem version.
rspec_base = File.expand_path(File.dirname(__FILE__) + '/../../vendor/plugins/rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base)
begin
  require 'spec/rake/spectask'
  require 'cucumber/rake/task'

  spec_prereq = File.exist?(File.join(RAILS_ROOT, 'config', 'database.yml')) ? "db:test:prepare" : :noop
  task :noop do
  end

  task :default => :spec
  task :stats => "spec:statsetup"

  desc 'Run all specs in spec directory (excluding plugin & generator specs)'
  task :spec => spec_prereq do
    errors = %w(spec:integration spec:models spec:controllers spec:views spec:helpers spec:lib spec:generators spec:extensions).collect do |task|
      begin
        puts %{\nRunning #{task.gsub('spec:', '').titlecase} Spec Task}
        Rake::Task[task].invoke
        nil
      rescue => e
        task
      ensure
        if task == 'spec:integration'
          Rake::Task["db:test:load"].reenable
          Rake::Task["db:schema:load"].reenable
          Rake::Task["db:test:prepare"].execute
        end
      end
    end.compact
    abort "Errors running #{errors.to_sentence}!" if errors.any?
  end

  namespace :spec do
    desc "Run all specs in spec directory with RCov (excluding plugin & generator specs)"
    Spec::Rake::SpecTask.new(:rcov) do |t|
      t.spec_opts = ['--options', "\"#{RADIANT_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList.new('spec/**/*_spec.rb') do |fl|
        fl.exclude(/generator/)
      end
      t.rcov = true
      t.rcov_opts = lambda do
        IO.readlines("#{RADIANT_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
      end
    end
  
    desc "Print Specdoc for all specs (excluding plugin & generator specs)"
    Spec::Rake::SpecTask.new(:doc) do |t|
      t.spec_opts = ["--format", "specdoc", "--dry-run"]
      t.spec_files = FileList.new('spec/**/*_spec.rb') do |fl|
        fl.exclude(/generator/)
      end
    end

    desc "Print Specdoc for all plugin specs"
    Spec::Rake::SpecTask.new(:plugin_doc) do |t|
      t.spec_opts = ["--format", "specdoc", "--dry-run"]
      t.spec_files = FileList['vendor/plugins/**/spec/**/*_spec.rb'].exclude('vendor/plugins/rspec/*')
    end

    [:models, :controllers, :views, :helpers, :lib].each do |sub|
      desc "Run the specs under spec/#{sub}"
      Spec::Rake::SpecTask.new(sub => spec_prereq) do |t|
        t.spec_opts = ['--options', "\"#{RADIANT_ROOT}/spec/spec.opts\""]
        t.spec_files = FileList["#{RADIANT_ROOT}/spec/#{sub}/**/*_spec.rb"]
      end
    end
    Cucumber::Rake::Task.new(:integration)# do |t|
    #   t.cucumber_opts = ["--format","progress"]
    #   t.feature_pattern = "#{RADIANT_ROOT}/features/**/*.feature"
    # end
  
    desc 'Run all specs in spec/generators directory'
    task :generators => spec_prereq do
      errors = ['spec:generators:extension_controller', 'spec:generators:extension_mailer', 
                'spec:generators:extension_migration', 'spec:generators:extension_model',
                'spec:generators:extension', 'spec:generators:instance'].collect do |task|
        begin
          Rake::Task[task].invoke
          nil
        rescue => e
          task
        end
      end.compact
      abort "Errors running #{errors.to_sentence}!" if errors.any?
    end
  
    namespace :generators do
      [:extension_controller, :extension_mailer, :extension_migration, :extension_model, :extension, :instance].each do |generator|
        desc "Run the spec at spec/geneartors/#{generator}_generator_spec.rb"
        Spec::Rake::SpecTask.new(generator => spec_prereq) do |t|
          t.spec_opts = ['--options', "\"#{RADIANT_ROOT}/spec/spec.opts\""]
          t.spec_files = [File.join(RADIANT_ROOT, "spec/generators/#{generator}_generator_spec.rb")]
        end
      end
    end
  
    desc "Run the specs under vendor/plugins (except RSpec's own)"
    Spec::Rake::SpecTask.new(:plugins => spec_prereq) do |t|
      t.spec_opts = ['--options', "\"#{RADIANT_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList['vendor/plugins/**/spec/**/*_spec.rb'].exclude('vendor/plugins/rspec/*').exclude("vendor/plugins/rspec-rails/*")
    end
  
    namespace :plugins do
      desc "Runs the examples for rspec_on_rails"
      Spec::Rake::SpecTask.new(:rspec_on_rails) do |t|
        t.spec_opts = ['--options', "\"#{RADIANT_ROOT}/spec/spec.opts\""]
        t.spec_files = FileList['vendor/plugins/rspec-rails/spec/**/*_spec.rb']
      end
    end

    # Setup specs for stats
    task :statsetup do
      require 'code_statistics'
      ::STATS_DIRECTORIES << %w(Model\ specs spec/models) if File.exist?('spec/models')
      ::STATS_DIRECTORIES << %w(View\ specs spec/views) if File.exist?('spec/views')
      ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers) if File.exist?('spec/controllers')
      ::STATS_DIRECTORIES << %w(Helper\ specs spec/helpers) if File.exist?('spec/helpers')
      ::STATS_DIRECTORIES << %w(Library\ specs spec/lib) if File.exist?('spec/lib')
      ::STATS_DIRECTORIES << %w(Integration\ specs spec/integration) if File.exist?('spec/integration')
      ::STATS_DIRECTORIES << %w(Generator\ specs spec/generators) if File.exist?('spec/generators')
      ::CodeStatistics::TEST_TYPES << "Model specs" if File.exist?('spec/models')
      ::CodeStatistics::TEST_TYPES << "View specs" if File.exist?('spec/views')
      ::CodeStatistics::TEST_TYPES << "Controller specs" if File.exist?('spec/controllers')
      ::CodeStatistics::TEST_TYPES << "Helper specs" if File.exist?('spec/helpers')
      ::CodeStatistics::TEST_TYPES << "Library specs" if File.exist?('spec/lib')
      ::CodeStatistics::TEST_TYPES << "Generator specs" if File.exist?('spec/generators')
      ::STATS_DIRECTORIES.delete_if {|a| a[0] =~ /test/}
    end

    namespace :db do
      namespace :fixtures do
        desc "Load fixtures (from spec/fixtures) into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
        task :load => :environment do
          require 'active_record/fixtures'
          ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
          (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RADIANT_ROOT, 'spec', 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
            Fixtures.create_fixtures('spec/fixtures', File.basename(fixture_file, '.*'))
          end
        end
      end
    end

    namespace :server do
      daemonized_server_pid = File.expand_path("spec_server.pid", RAILS_ROOT + "/tmp")

      desc "start spec_server."
      task :start do
        if File.exist?(daemonized_server_pid)
          $stderr.puts "spec_server is already running."
        else
          $stderr.puts "Starting up spec server."
          system("ruby", "script/spec_server", "--daemon", "--pid", daemonized_server_pid)
        end
      end

      desc "stop spec_server."
      task :stop do
        unless File.exist?(daemonized_server_pid)
          $stderr.puts "No server running."
        else
          $stderr.puts "Shutting down spec_server."
          system("kill", "-s", "TERM", File.read(daemonized_server_pid).strip) && 
          File.delete(daemonized_server_pid)
        end
      end

      desc "reload spec_server."
      task :restart do
        unless File.exist?(daemonized_server_pid)
          $stderr.puts "No server running."
        else
          $stderr.puts "Reloading down spec_server."
          system("kill", "-s", "USR2", File.read(daemonized_server_pid).strip)
        end
      end
    end
  end
rescue LoadError
  task :spec_prereq do
    puts "Required dependencies RSpec, RSpec-Rails or Cucumber are missing.\nRun 'rake gems:install RAILS_ENV=test'"
  end
  
  task :spec => :spec_prereq
  namespace :spec do
    %w(integration models controllers views helpers lib generators).each do |t|
      task t => :spec_prereq
    end
    
    namespace :generators do
      [:extension_controller, :extension_mailer, :extension_migration, :extension_model, :extension, :instance].each do |t|
        task t => :spec_prereq
      end
    end
    
    task :plugins => :spec_prereq
    namespace :plugins do
      task :rspec_on_rails => :spec_prereq
    end
    
    task :statsetup => :spec_prereq
    
    namespace :db do
      namespace :fixtures do
        task :load => :spec_prereq
      end
    end
    
    namespace :server do
      [:start, :stop, :restart].each do |t|
        task t => :spec_prereq
      end
    end
  end
end