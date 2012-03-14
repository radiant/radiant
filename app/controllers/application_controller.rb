require_dependency 'radiant'

class ApplicationController < ActionController::Base
  include LoginSystem
  
  filter_parameter_logging :password, :password_confirmation
  
  protect_from_forgery
  
  before_filter :set_current_user
  before_filter :set_timezone
  before_filter :set_user_locale
  before_filter :set_javascripts_and_stylesheets
  before_filter :force_utf8_params if RUBY_VERSION =~ /1\.9/
  before_filter :set_standard_body_style, :only => [:new, :edit, :update, :create]
  
  attr_accessor :config, :cache
  attr_reader :pagination_parameters
  helper_method :pagination_parameters
  
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
      UserActionObserver.instance.current_user = current_user
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
    
    # When using Radiant with Ruby 1.9, the strings that come in from forms are ASCII-8BIT encoded.
    # That causes problems, especially when using special chars and with certain DBs, like DB2
    # That's why we force the encoding of the params to UTF-8
    # That's what's happening in Rails 3, too: https://github.com/rails/rails/commit/25215d7285db10e2c04d903f251b791342e4dd6a
    #
    # See http://stackoverflow.com/questions/8268778/rails-2-3-9-encoding-of-query-parameters
    # See https://rails.lighthouseapp.com/projects/8994/tickets/4807
    # See http://jasoncodes.com/posts/ruby19-rails2-encodings (thanks for the following code, Jason!)
    def force_utf8_params      
      traverse = lambda do |object, block|
        if object.kind_of?(Hash)
          object.each_value { |o| traverse.call(o, block) }
        elsif object.kind_of?(Array)
          object.each { |o| traverse.call(o, block) }
        else
          block.call(object)
        end
        object
      end
      force_encoding = lambda do |o|
        o.force_encoding(Encoding::UTF_8) if o.respond_to?(:force_encoding)
      end
      traverse.call(params, force_encoding)
    end
    
end
