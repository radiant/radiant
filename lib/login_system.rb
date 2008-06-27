module LoginSystem
  def self.append_features(base)
    base.class_eval %{
      before_filter :authenticate
      
      @@controllers_where_no_login_required = []
      @@controller_permissions = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = Hash.new } }
      helper_method :current_user
    }
    base.extend ClassMethods
    super
  end
  
  protected
  
    def current_user
      @current_user ||= User.find(session['user_id']) rescue nil
    end
    
    def current_user=(value=nil)
      if value && value.is_a?(User)
        @current_user = value
        session['user_id'] = value.id 
      else
        @current_user = nil
        session['user_id'] = nil
      end
      @current_user
    end
    
    def authenticate
      action = params['action'].to_s.intern
      login_from_cookie
      if no_login_required? or (current_user and user_has_access_to_action?(action))
        true
      else
        if current_user
          permissions = self.class.controller_permissions[self.class][action]
          flash[:error] = permissions[:denied_message] || 'Access denied.'
          redirect_to permissions[:denied_url] || { :action => :index }
        else
          session[:return_to] = request.request_uri
          redirect_to login_url
        end
        false
      end
    end
  
    def no_login_required?
      controllers = self.class.controllers_where_no_login_required
      controllers.include?(self.class)
    end
  
    def user_has_role?(role)
      current_user.send("#{role}?")
    end
    
    def user_has_access_to_action?(action)
      permissions = self.class.controller_permissions[self.class][action]
      case
      when allowed_roles = permissions[:when]
        allowed_roles = [allowed_roles].flatten
        allowed_roles.each do |role|
          return true if user_has_role?(role)
        end
        false
      when condition_method = permissions[:if]
        send(condition_method)
      else
        true
      end
    end

    def login_from_cookie
      if !cookies[:session_token].blank? && user = User.find_by_session_token(cookies[:session_token]) # don't find by empty value
        user.remember_me
        self.current_user = user
        set_session_cookie
      end
    end

    def set_session_cookie
      cookies[:session_token] = { :value => current_user.session_token , :expires => Radiant::Config['session_timeout'].to_i.from_now.utc }
    end
  
  module ClassMethods
    def no_login_required
      controllers_where_no_login_required << self
      class << self
        def inherited(subclass)
          super(subclass)
          controllers_where_no_login_required << subclass
        end
      end
    end
    
    def login_required
      controllers_where_no_login_required.delete self
      class << self
        def inherited(subclass)
          super(subclass)
          controllers_where_no_login_required.delete subclass
        end
      end
    end
    
    def only_allow_access_to(*args)
      options = {}
      options = args.pop.dup if args.last.kind_of?(Hash)
      options.symbolize_keys!
      actions = args.map { |a| a.to_s.intern }
      actions.each do |action|
        controller_permissions[self][action] = options
      end
    end
    
    def controller_permissions
      self.class_eval %{ @@controller_permissions }
    end
    
    def controllers_where_no_login_required
      self.class_eval %{ @@controllers_where_no_login_required }
    end
  end
end