# Replaces the legacy ActiveRecord::Observer pattern.
# Stamps created_by/updated_by on models and tracks the current user per-thread.
class UserActionObserver
  include Singleton

  def current_user=(user)
    Thread.current[:current_user] = user
  end

  def current_user
    Thread.current[:current_user]
  end

  def self.current_user=(user)
    instance.current_user = user
  end

  def self.current_user
    instance.current_user
  end
end
