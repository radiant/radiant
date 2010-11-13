require 'radiant'
require 'rails'

module Radiant
  #class Application < Rails::Engine
  #
  #end

  class Engine < Rails::Engine
    require 'radiant/core_ext'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    # config.autoload_paths += %W( #{config.root}/extras )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    config.active_record.observers = :user_action_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :de

    # This is a thin wrapper around Rack::Cache middleware.
    #
    # Comment out this line if you want to turn off all caching, or
    # add options to modify the behavior. In the majority of deployment
    # scenarios it is desirable to leave Radiant's cache enabled and in
    # the default configuration.
    initializer "radiant.add_middleware" do |app|
      require 'radiant/cache'

      app.middleware.insert_after Rack::Sendfile, Radiant::Cache, :verbose => true
    end

    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end

    # Configure generators values. Many other options are available, be sure to check the documentation.
    config.generators do |g|
      g.orm             :active_record
      g.template_engine :haml
      g.test_framework  :rspec, :fixture => false
    end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    initializer "haml" do
      require 'haml'
      require 'sass'
      Haml::Template.options[:format] = :html5
      Haml::Template.options[:ugly] = Rails.env.production?
    end

    initializer "admin_ui" do
      require 'radiant/admin_ui'
      AdminUI.instance.load_default_nav
    end

    require 'radiant/extension'
    Dir["#{config.root}/../extensions/*/*_extension.rb"].each do |extension|
      require extension
    end

    # TODO: Confirm this is the best place for these
    require 'acts_as_tree'
    require 'will_paginate'

    initializer "activate extensions" do
      extensions = Rails.application.railties.engines.select { |e| e.is_a? Radiant::Extension }
      extensions.each do |ext|
        ext.activate if ext.respond_to? :activate
      end
    end
    
    config.secret_token = "4ac217d6512aae25ea83a25d58c30bed06520ac20ff8040da552f88d3046cf9103c1a7ca21254c9fc64a6f3dd59e00e206e7c410d612390be23d834b48f7b1e8"

    config.action_view.field_error_proc = Proc.new do |html, instance|
      if html !~ /label/
        %{<span class="error-with-field">#{html} <span class="error">&bull; #{[instance.error_message].flatten.first}</span></span>}.html_safe
      else
        html
      end
    end
  end

  module Version
    Major = '0'
    Minor = '9'
    Tiny  = '1'
    Patch = nil # set to nil for normal release

    class << self
      def to_s
        [Major, Minor, Tiny, Patch].delete_if{|v| v.nil? }.join('.')
      end
      alias :to_str :to_s
    end
  end

  def self.loaded_via_gem?
    false
  end

  def self.app?
    true
  end

end
