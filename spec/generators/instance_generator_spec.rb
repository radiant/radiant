require File.dirname(__FILE__) + "/extension_generators_spec_helper"

shared_examples_for "all instance generators" do
  # Check for directories
  %w(config config/environments config/initializers db log script vendor/plugins vendor/extensions
    public public/images public/stylesheets public/images/admin public/stylesheets/admin public/stylesheets/sass
    public/stylesheets/sass/admin script/performance script/process).each do |dir|
    it "should have a #{dir} directory" do
      ''.should have_generated_directory(dir)
    end
  end
  
  # Check for files
  %w(CHANGELOG CONTRIBUTORS LICENSE INSTALL README Rakefile).each do |file|
    it "should have a #{file}" do
      ''.should have_generated_file(file)
    end
  end
  
  # Check for configs
  %w(boot.rb routes.rb environments/production.rb environments/development.rb environments/test.rb).each do |file|
    it "should have a #{file} config file" do
      'config'.should have_generated_file(file)
    end
  end
  
  # Check for public files
  %w(.htaccess robots.txt 404.html 500.html favicon.ico dispatch.cgi dispatch.fcgi dispatch.rb).each do |file|
    it "should have a #{file} in public/" do
      'public'.should have_generated_file(file)
    end
  end
  
  # Check for scripts
  %w(about breakpointer cucumber extension runner spec version autospec console dbconsole generate server 
    spec_server performance/benchmarker performance/profiler performance/request process/inspector 
    process/reaper process/spawner process/spinner).each do |file|
    it "should have a #{file} script" do
      'script'.should have_generated_file(file)
    end
  end
  
  # Check for admin sass/css
  %w(main.css modules/_links.sass 
    partials/_avatars.sass partials/_footer.sass partials/_layout.sass main.sass 
    _base.sass partials/_forms.sass partials/_messages.sass partials/_content.sass 
    partials/_header.sass partials/_popup.sass partials/_tabcontrol.sass partials/_dateinput.sass 
    partials/_toolbar.sass).each do |file|
    if file.ends_with?('.css')
      it "should have a #{file} css file" do
        'public/stylesheets/admin'.should have_generated_file(file)
      end
    elsif file.ends_with?('.sass')
      it "should have a #{file} sass file" do 
        'public/stylesheets/sass/admin'.should have_generated_file(file)
      end
    end
  end
  
  # Check for admin images
  %w(navigation_secondary_separator.gif add_tab.png minus_disabled.png
     snippet.png brown_bottom_line.gif single_form_shadow.png
    spinner.gif collapse.png 
    status_background.png draft_page.png status_bottom_left.png expand.png page.png 
    status_bottom_right.png layout.png plus.png status_spinner.gif plus_grey.png 
    status_top_left.png metadata_toggle.png popup_border_background.png status_top_right.png minus.png 
    popup_border_bottom_left.png tab_close.png minus_grey.png popup_border_bottom_right.png 
    popup_border_top_left.png 
    popup_border_top_right.png virtual_page.png).each do |file|
    it "should have a #{file} admin image" do
      'public/images/admin'.should have_generated_file(file)
    end
  end
  
  # Check for admin javascripts
  %w(application.js controls.js dragdrop.js lowpro.js popup.js pagefield.js ruledtable.js sitemap.js
    tabcontrol.js codearea.js cookie.js effects.js prototype.js shortcuts.js status.js utility.js).each do |file|
    it "should have a #{file} admin image" do
      'public/javascripts/admin'.should have_generated_file(file)
    end
  end

  # Check for initializers
  # initializers are now run from RADIANT_ROOT before the instance, 
  # so most of those are should no longer be copied across
  %w(radiant_config.rb).each do |file|
    it "should have a #{file} initializer" do
      'config/initializers'.should have_generated_file(file)
    end
  end
  %w(haml.rb compass.rb).each do |file|
    it "should not have a #{file} initializer" do
      'config/initializers'.should_not have_generated_file(file)
    end
  end 
end

describe "IntanceGenerator" do
  include FileUtils
  include GeneratorSpecHelperMethods
  Rails::Generator::Base.prepend_sources(Rails::Generator::PathSource.new(:radiant, File.join(BASE_ROOT, 'lib', 'generators')))
  
  describe('with no options') do
    it_should_behave_like "all instance generators"

    before(:all) do
      with_radiant_root_as_base_root { suppress_stdout { run_generator('instance', [RAILS_ROOT]) } }
    end

    after(:all) do
      FileUtils.rm_rf Dir["#{RADIANT_ROOT}"]
    end
  end

  { 'db2'=>'ibm_db', 'mysql'=>'mysql', 'postgresql'=>'postgresql', 
    'sqlite3'=>'sqlite3', 'sqlserver'=>'sqlserver' }.each do |db, adapter|
    describe("with #{db} database option") do
      it_should_behave_like "all instance generators"

      before(:all) do
        with_radiant_root_as_base_root { suppress_stdout { run_generator('instance', ['-d', db, RAILS_ROOT]) } }
      end

      it "should generate database.yml with adapter #{adapter} for #{db}" do
        'config'.should have_generated_yaml('database') do |yaml|
          %w(production development test).each {|env| yaml[env]['adapter'].should == adapter}
        end
      end
    
      after(:all) do
        FileUtils.rm_rf Dir["#{RADIANT_ROOT}"]
      end
    end
  end
  
  describe('with shebang option') do
    it_should_behave_like "all instance generators"

    before(:all) do
      @shebang = '/my/path/to/ruby'
      with_radiant_root_as_base_root { suppress_stdout { run_generator('instance', ['-r', @shebang, RAILS_ROOT]) } }
      @files = Dir.glob("#{RADIANT_ROOT}/script/**/*") + Dir.glob("#{RADIANT_ROOT}/public/dispatch*")
      @files.collect! {|i| [i, i.gsub(/\A#{Regexp.escape(RADIANT_ROOT)}\//, '')] }
    end
    
    it 'should set shebang for scripts & dispatchers' do
      @files.each do |fn, f|
        next if File.directory?(fn)
        ''.should have_generated_file(f) do |body|
          body.should match(/\A\#\!#{@shebang}\n/), "#{f} should have shebang '\#!#{@shebang}' but has '#{body.match(/\A(.*)\n/)[1]}'"
        end
      end
    end
    
    after(:all) do
      FileUtils.rm_rf Dir["#{RADIANT_ROOT}"]
    end
  end
end
