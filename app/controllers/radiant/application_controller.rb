require_dependency 'radiant'
require 'login_system'

module Radiant
  class ApplicationController < ::ActionController::Base
    include ::LoginSystem

    before_filter :set_timezone
    before_filter :set_javascripts_and_stylesheets

    attr_accessor :cache
    attr_reader :pagination_parameters, :detail
    helper_method :pagination_parameters

    def initialize
      super
      @detail = Radiant.detail
    end

    # helpers to include additional assets from actions or views
    helper_method :include_stylesheet, :include_javascript

    def include_stylesheet(sheet)
      @stylesheets << sheet
    end

    def include_javascript(script)
      @javascripts << script
    end

    def template_name
      case self.action_name
      when 'index'
        'index'
      when 'new','create'
        'new'
      when 'show'
        'show'
      when 'edit', 'update'
        'edit'
      when 'remove', 'destroy'
        'remove'
      else
        self.action_name
      end
    end

    def rescue_action_in_public(exception)
      case exception
        when ActiveRecord::RecordNotFound, ActionController::UnknownController, ActionController::UnknownAction, ActionController::RoutingError
          render template: "radiant/site/not_found", status: 404
        else
          super
      end
    end

    private

      def set_javascripts_and_stylesheets
        @stylesheets ||= []
        @stylesheets.concat %w(admin/main)
        @javascripts ||= []
      end

      def set_timezone
        Time.zone = Radiant.detail['local.timezone'].presence || Time.zone_default
      end

  end
end
