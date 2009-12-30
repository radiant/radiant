require_dependency 'radiant'

class ApplicationController < ActionController::Base
  include LoginSystem
  include Radiant::LegacyRoutes
  
  filter_parameter_logging :password, :password_confirmation
  
  protect_from_forgery
  
  before_filter :set_current_user
  before_filter :set_timezone
  before_filter :set_user_locale
  before_filter :set_javascripts_and_stylesheets
  before_filter :set_standard_body_style, :only => [:new, :edit]
  
  attr_accessor :config, :cache
  
  def initialize
    super
    @config = Radiant::Config
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

end
