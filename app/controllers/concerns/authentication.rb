module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_login
    helper_method :current_user, :logged_in?
  end

  class_methods do
    def skip_login_required
      skip_before_action :require_login
    end

    def require_role(*roles, except: nil, only: nil, denied_url: nil, denied_message: "Access denied.")
      self.role_requirements ||= {}
      actions = Array(only)
      if actions.any?
        actions.each { |a| self.role_requirements[a.to_s] = roles }
      else
        self.role_requirements[:all] = roles
      end

      before_action(only: only, except: except) do
        unless current_user && roles.any? { |role| current_user.has_role?(role) }
          flash[:error] = denied_message
          respond_to do |format|
            format.html { redirect_to(denied_url || admin_pages_path) }
            format.any(:xml, :json) { head :forbidden }
          end
        end
      end
    end

    def role_requirements
      @role_requirements
    end

    def role_requirements=(val)
      @role_requirements = val
    end

    def user_has_access_to_action?(user, action)
      reqs = role_requirements
      return true unless reqs
      roles = reqs[action.to_s] || reqs[:all]
      return true unless roles
      roles.any? { |role| user.has_role?(role) }
    end
  end

  private

  def current_user
    @current_user ||= find_current_user
  end

  def current_user=(user)
    @current_user = user
    session[:user_id] = user&.id
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if current_user

    session[:return_to] = request.fullpath
    respond_to do |format|
      format.html { redirect_to login_url }
      format.any(:xml, :json) { request_http_basic_authentication }
    end
  end

  def find_current_user
    login_from_session || login_from_http
  end

  def login_from_session
    User.find_by(id: session[:user_id])
  end

  def login_from_http
    if [Mime[:xml], Mime[:json]].include?(request.format)
      authenticate_with_http_basic do |login_or_email, password|
        User.authenticate(login_or_email, password)
      end
    end
  end
end
