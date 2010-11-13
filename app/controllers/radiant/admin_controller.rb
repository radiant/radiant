require_dependency 'radiant/legacy_routes'

class ApplicationController < ActionController::Base
  include Radiant::LegacyRoutes
  
  protect_from_forgery
  
  before_filter :set_current_user
  before_filter :set_timezone
  before_filter :set_user_locale
  before_filter :set_javascripts_and_stylesheets
  before_filter :set_standard_body_style, :only => [:new, :edit, :update, :create]
  
  attr_reader :pagination_parameters
  helper_method :pagination_parameters

  # helpers to include additional assets from actions or views
  helper_method :include_stylesheet, :include_javascript

  helper 'radiant/admin'
  
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
        render :template => "site/not_found", :status => 404
      else
        super
    end
  end
  
  private
  
    def set_current_user
      UserActionObserver.current_user = current_user
    end  
        
    def set_user_locale      
      I18n.locale = current_user && !current_user.locale.blank? ? current_user.locale : Radiant::Config['default_locale']
    end

    def set_timezone
      Time.zone = Radiant::Config['local.timezone'] || Time.zone_default
    end
  
    def set_javascripts_and_stylesheets
      @stylesheets ||= []
      @stylesheets.concat %w(admin/main)
      @javascripts ||= []
    end

    def set_standard_body_style
      @body_classes ||= []
      @body_classes.concat(%w(reversed))
    end
    
  class << self
    # TODO MOVE
    def only_allow_access_to(*args)
      options = {}
      options = args.pop.dup if args.last.kind_of?(Hash)
      options.symbolize_keys!
      actions = args.map { |a| a.to_s.intern }
      actions.each do |action|
        controller_permissions[action] = options
      end
    end
    
    def controller_permissions
      @controller_permissions ||= Hash.new { |h,k| h[k.to_s.intern] = Hash.new }
    end
  end
    
end
