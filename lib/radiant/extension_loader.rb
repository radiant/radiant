require 'radiant/extension'
require 'active_support/dependencies'
require 'method_observer'

module Radiant
  class ExtensionLoader
    # The ExtensionLoader is reponsible for the loading, activation and reactivation of extensions. 
    # The noticing of important subdirectories is now handled by the ExtensionPath class.

    class DependenciesObserver < MethodObserver
      attr_accessor :config

      def initialize #(rails_config)
        #@config = rails_config
      end

      def before_clear(*args)
        ExtensionLoader.deactivate_extensions
      end

      def after_clear(*args)
        ExtensionLoader.load_extensions
        ExtensionLoader.activate_extensions
      end
    end

    attr_accessor :initializer, :extensions

    include Simpleton

    def initialize
    end

    def extensions
      Rails.application.railties.engines.select { |e| e.is_a? Radiant::Extension }
    end

    def load_extensions
      @observer ||= DependenciesObserver.new.observe(::ActiveSupport::Dependencies)
      core_extensions.each { |extension| load_extension(extension) }
      vendor_extensions.each { |extension| load_extension(extension) }
    end

    def activate_extensions
      # Reset the view paths after

      initialize_default_admin_tabs

      initialize_framework_views

      # Reset the admin UI regions
      admin.load_default_regions

      # Make sure we have our subclasses loaded!
      Page.load_subclasses

      extensions.each do |extension|
        extension.activate if extension.respond_to? :activate
      end
    end

    def deactivate_extensions
      extensions.each do |extension|
        extension.deactivate if extension.respond_to? :deactivate
      end
    end

private
    def admin
      AdminUI.instance
    end

    def core_extensions
      Dir["#{File.dirname(__FILE__)}/../../vendor/extensions/*/*_extension.rb"]
    end

    def vendor_extensions
      # TODO: Work out how the hell we do this when Radiant is installed as a gem
      Dir["#{File.dirname(__FILE__)}/../../../../vendor/extensions/*/*_extension.rb"]
    end

    def load_extension(extension_path)
      require extension_path
    end

    def initialize_framework_views
      # view_paths = [].tap do |arr|
      #   # Add the singular view path if it's not in the list
      #   arr << configuration.view_path if !configuration.view_paths.include?(configuration.view_path)
      #   # Add the default view paths
      #   arr.concat configuration.view_paths
      #   # Add the extension view paths
      #   arr.concat extension_loader.view_paths
      #   # Reverse the list so extensions come first
      #   arr.reverse!
      # end
      # if configuration.frameworks.include?(:action_mailer) || defined?(ActionMailer::Base)
      #   # This happens before the plugins are loaded so we must load it manually
      #   unless ActionMailer::Base.respond_to? :view_paths
      #     require "#{RADIANT_ROOT}/lib/plugins/extension_patches/lib/mailer_view_paths_extension"
      #   end
      #   ActionMailer::Base.view_paths = ActionView::Base.process_view_paths(view_paths)
      # end
      # if configuration.frameworks.include?(:action_controller) || defined?(ActionController::Base)
      #   view_paths.each do |vp|
      #     unless ActionController::Base.view_paths.include?(vp)
      #       ActionController::Base.prepend_view_path vp
      #     end
      #   end
      # end
    end

    def initialize_default_admin_tabs
      admin.nav.clear
      admin.load_default_nav
    end

    def configuration
      Radiant::Configuration
    end
  end
end
