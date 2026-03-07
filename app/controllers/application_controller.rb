class ApplicationController < ActionController::Base
  include LoginSystem
  
  protect_from_forgery
  
  before_action :set_current_user
  before_action :set_timezone
  before_action :set_user_locale
  before_action :set_javascripts_and_stylesheets
  before_action :set_standard_body_style, :only => [:new, :edit, :update, :create]
  
  attr_accessor :cache
  attr_reader :pagination_parameters
  helper_method :pagination_parameters
  
  
  # helpers to include additional assets from actions or views
  helper_method :include_stylesheet, :include_javascript
  
  def include_stylesheet(sheet)
    @stylesheets << sheet
  end
  
  def include_javascript(script)
    # Skip legacy JS includes - assets no longer exist
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
    
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def not_found
    render template: "site/not_found", status: 404
  end
  
  private
  
    def set_current_user
      UserActionObserver.instance.current_user = current_user
    end  
        
    def set_user_locale      
      I18n.locale = current_user && !current_user.locale.blank? ? current_user.locale : Radiant::Config['default_locale']
    end

    def set_timezone
      tz = Radiant::Config['local.timezone']
      Time.zone = tz.present? ? tz : Time.zone_default
    end
  
    def set_javascripts_and_stylesheets
      @stylesheets ||= []
      @javascripts ||= []
    end

    def set_standard_body_style
      @body_classes ||= []
      @body_classes.concat(%w(reversed))
    end
    
    
end
