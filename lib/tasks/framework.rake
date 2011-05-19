# Only define freeze and unfreeze tasks in instance mode
unless File.directory? "#{RAILS_ROOT}/app"
  namespace :radiant do
    namespace :freeze do
      desc "Lock this application to the current gems (by unpacking them into vendor/radiant)"
      task :gems do
        require 'rubygems'
        require 'rubygems/gem_runner'

        radiant = (version = ENV['VERSION']) ?
          Gem.cache.search('radiant', "= #{version}").first :
          Gem.cache.search('radiant').sort_by { |g| g.version }.last

        version ||= radiant.version

        unless radiant
          puts "No radiant gem #{version} is installed.  Do 'gem list radiant' to see what you have available."
          exit
        end

        puts "Freezing to the gems for Radiant #{radiant.version}"
        rm_rf   "vendor/radiant"

        chdir("vendor") do
          Gem::GemRunner.new.run(["unpack", "radiant", "--version", "=#{version}"])
          FileUtils.mv(Dir.glob("radiant*").first, "radiant")
        end
      end

      desc "Lock to latest Edge Radiant or a specific revision with REVISION=X (ex: REVISION=245484e), a tag with TAG=Y (ex: TAG=0.6.6), or a branch with BRANCH=Z (ex: BRANCH=mental)"
      task :edge do
        $verbose = false
        unless system "git --version"
          $stderr.puts "ERROR: Must have git available in the PATH to lock this application to Edge Radiant"
          exit 1
        end

        radiant_git = "git://github.com/radiant/radiant.git"

        if File.exist?("vendor/radiant/.git/HEAD")
          cd("vendor/radiant") { system "git checkout master"; system "git pull origin master"}        
        else
          system "git clone #{radiant_git} vendor/radiant"
        end

        case
        when ENV['TAG']
          cd("vendor/radiant") { system "git checkout -b v#{ENV['TAG']} #{ENV['TAG']}"} 
        when ENV['BRANCH']
          cd("vendor/radiant") { system "git checkout --track -b #{ENV['BRANCH']} origin/#{ENV['BRANCH']}"} 
        when ENV['REVISION']
          cd("vendor/radiant") { system "git checkout -b REV_#{ENV['REVISION']} #{ENV['REVISION']}"} 
        end

        cd("vendor/radiant") { system "git submodule update --init"}        
      end
    end

    desc "Unlock this application from freeze of gems or edge and return to a fluid use of system gems"
    task :unfreeze do
      rm_rf "vendor/radiant"
    end

    desc "Update configs, scripts, html, images, sass, stylesheets and javascripts from Radiant."
    task :update do
      tasks = %w{scripts javascripts configs static_html images sass stylesheets cached_assets}
      tasks = tasks & ENV['ONLY'].split(',') if ENV['ONLY']
      tasks = tasks - ENV['EXCEPT'].split(',') if ENV['EXCEPT']
      tasks.each do |task| 
        puts "* Updating #{task}"
        Rake::Task["radiant:update:#{task}"].invoke
      end
    end

    namespace :update do
      desc "Add new scripts to the instance script/ directory"
      task :scripts do
        local_base = "script"
        edge_base  = "#{File.dirname(__FILE__)}/../../script"

        local = Dir["#{local_base}/**/*"].reject { |path| File.directory?(path) }
        edge  = Dir["#{edge_base}/**/*"].reject { |path| File.directory?(path) }
        edge  = edge.reject { |f| f =~ /(generate|plugin|destroy)$/ }

        edge.each do |script|
          base_name = script[(edge_base.length+1)..-1]
          next if local.detect { |path| base_name == path[(local_base.length+1)..-1] }
          if !File.directory?("#{local_base}/#{File.dirname(base_name)}")
            mkdir_p "#{local_base}/#{File.dirname(base_name)}"
          end
          install script, "#{local_base}/#{base_name}", :mode => 0755
        end
        install "#{File.dirname(__FILE__)}/../generators/instance/templates/instance_generate", "#{local_base}/generate", :mode => 0755
      end

      desc "Update your javascripts from your current radiant install"
      task :javascripts do
        FileUtils.mkdir_p("#{RAILS_ROOT}/public/javascripts/admin/")
        copy_javascripts = proc do |project_dir, scripts|
          scripts.reject!{|s| File.basename(s) == 'overrides.js'} if File.exists?(project_dir + 'overrides.js')
          FileUtils.cp(scripts, project_dir)
        end
        copy_javascripts[RAILS_ROOT + '/public/javascripts/', Dir["#{File.dirname(__FILE__)}/../../public/javascripts/*.js"]]
        copy_javascripts[RAILS_ROOT + '/public/javascripts/admin/', Dir["#{File.dirname(__FILE__)}/../../public/javascripts/admin/*.js"]]
      end

      desc "Update the cached assets for the admin UI"
      task :cached_assets do
        TaskSupport.cache_admin_js
      end

      desc "Update config/boot.rb from your current radiant install"
      task :configs do
        require 'erb'
        FileUtils.cp("#{File.dirname(__FILE__)}/../generators/instance/templates/instance_boot.rb", RAILS_ROOT + '/config/boot.rb')
        instances = {
          :env          => "#{RAILS_ROOT}/config/environment.rb",
          :development  => "#{RAILS_ROOT}/config/environments/development.rb",
          :test         => "#{RAILS_ROOT}/config/environments/test.rb",
          :production   => "#{RAILS_ROOT}/config/environments/production.rb"
        }
        tmps = {
          :env          => "#{RAILS_ROOT}/config/environment.tmp",
          :development  => "#{RAILS_ROOT}/config/environments/development.tmp",
          :test         => "#{RAILS_ROOT}/config/environments/test.tmp",
          :production   => "#{RAILS_ROOT}/config/environments/production.tmp"
        }
        gens = {
          :env          => "#{File.dirname(__FILE__)}/../generators/instance/templates/instance_environment.rb",
          :development  => "#{File.dirname(__FILE__)}/../../config/environments/development.rb",
          :test         => "#{File.dirname(__FILE__)}/../../config/environments/test.rb",
          :production   => "#{File.dirname(__FILE__)}/../../config/environments/production.rb"
        }
        backups = {
          :env          => "#{RAILS_ROOT}/config/environment.bak",
          :development  => "#{RAILS_ROOT}/config/environments/development.bak",
          :test         => "#{RAILS_ROOT}/config/environments/test.bak",
          :production   => "#{RAILS_ROOT}/config/environments/production.bak"
        }
        @warning_start = "** WARNING **
The following files have been changed in Radiant. Your originals have 
been backed up with .bak extensions. Please copy your customizations to 
the new files:"
        [:env, :development, :test, :production].each do |env_type|
          File.open(tmps[env_type], 'w') do |f|
            app_name = File.basename(File.expand_path(RAILS_ROOT))
            f.write ERB.new(File.read(gens[env_type])).result(binding)
          end
          unless FileUtils.compare_file(instances[env_type], tmps[env_type])
            FileUtils.cp(instances[env_type], backups[env_type])
            FileUtils.cp(tmps[env_type], instances[env_type])
            @warnings ||= ""
            case env_type
            when :env
              @warnings << "
- config/environment.rb"
            else
              @warnings << "
- config/environments/#{env_type.to_s}.rb"
            end
          end
          FileUtils.rm(tmps[env_type])
        end
        if @warnings
          puts @warning_start + @warnings
        end
      end

      desc "Update static HTML files from your current radiant install"
      task :static_html do
        project_dir = RAILS_ROOT + "/public/"
        html_files = Dir["#{File.dirname(__FILE__)}/../../public/*.html"].delete_if { |f| f =~ /404.html|500.html/ }
        FileUtils.cp(html_files, project_dir)
      end

      desc "Update admin and radiant images from your current radiant install"
      task :images do
        %w{admin radiant}.each do |d|
          project_dir = RAILS_ROOT + "/public/images/#{d}/"
          FileUtils.mkdir_p(project_dir)
          images = Dir["#{File.dirname(__FILE__)}/../../public/images/#{d}/*"]
          FileUtils.cp(images, project_dir)
        end
      end

      desc "Update admin stylesheets from your current radiant install"
      task :stylesheets do
        project_dir = RAILS_ROOT + '/public/stylesheets/admin/'
        
        copy_stylesheets = proc do |project_dir, styles|
          styles.reject!{|s| File.basename(s) == 'overrides.css'} if File.exists?(project_dir + 'overrides.css')
          FileUtils.cp(styles, project_dir)
        end
        copy_stylesheets[RAILS_ROOT + '/public/stylesheets/admin/',Dir["#{File.dirname(__FILE__)}/../../public/stylesheets/admin/*.css"]]
      end

      desc "Update admin sass files from your current radiant install"
      task :sass do
        copy_sass = proc do |project_dir, sass_files|
          sass_files.reject!{|s| File.basename(s) == 'overrides.sass'} if File.exists?(project_dir + 'overrides.sass') || File.exists?(project_dir + '../overrides.css')
          sass_files.reject!{|s| File.directory?(s) }
          FileUtils.mkpath(project_dir)
          FileUtils.cp(sass_files, project_dir)
        end
        sass_dir = "#{RADIANT_ROOT}/public/stylesheets/sass/admin"
        copy_sass[RAILS_ROOT + '/public/stylesheets/sass/admin/', Dir["#{sass_dir}/*"]]
        Dir["#{sass_dir}/*"].each do |d|
          if File.directory?(d)
            copy_sass[RAILS_ROOT + "/public/stylesheets/sass/admin/#{File.basename(d)}/", Dir["#{d}/*"]]
          end
        end
      end

      # desc "Update initializers from your current radiant install"
      # task :initializers do
      #   project_dir = RAILS_ROOT + '/config/initializers/'
      #   FileUtils.mkpath project_dir
      #   initializers = Dir["#{File.dirname(__FILE__)}/../../config/initializers/*.rb"]
      #   FileUtils.cp(initializers, project_dir)
      # end
    end
  end
end