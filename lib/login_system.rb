module LoginSystem
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      prepend_before_filter :authenticate, :authorize
      helper_method :current_user
    end
  end

  protected

    def current_user
      @current_user ||= (login_from_session || login_from_cookie || login_from_http)
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
      if current_user
        session['user_id'] = current_user.id
        true
      else
        session[:return_to] = request.request_uri
        if params[:format].to_s =~ /xml|json/
          head :forbidden
        else
          redirect_to login_url
        end
      end
    end

    def authorize
      action = action_name.to_s.intern
      if user_has_access_to_action?(action)
        true
      else
        permissions = self.class.controller_permissions[action]
        flash[:error] = permissions[:denied_message] || 'Access denied.'
        redirect_to(permissions[:denied_url] || { :action => :index })
      end
    end

    def user_has_role?(role)
      current_user.send("#{role}?")
    end

    def user_has_access_to_action?(action)
      permissions = self.class.controller_permissions[action.to_s.intern]
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

    def login_from_session
      User.find(session['user_id']) rescue nil
    end

    def login_from_cookie
      if !cookies[:session_token].blank? && user = User.find_by_session_token(cookies[:session_token]) # don't find by empty value
        user.remember_me
        set_session_cookie(user)
        user
      end
    end

    def login_from_http
      if params[:format] =~ /xml|json/
        user = nil
        authenticate_or_request_with_http_basic do |user_name, password|
          user = User.authenticate(user_name, password)
        end
        user
      end
    end

    def set_session_cookie(user = current_user)
      cookies[:session_token] = { :value => user.session_token , :expires => Radiant::Config['session_timeout'].to_i.from_now.utc }
    end

  module ClassMethods
    def no_login_required
      skip_before_filter :authenticate
      skip_before_filter :authorize
    end

    def login_required?
      filter_chain.any? {|f| f.method == :authenticate || f.method == :authorize }
    end

    def login_required
      unless login_required?
        prepend_before_filter :authenticate, :authorize
      end
    end

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
