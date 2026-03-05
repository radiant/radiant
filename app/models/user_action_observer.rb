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

# Concern to include in models that need created_by/updated_by tracking
module UserActionStamps
  extend ActiveSupport::Concern

  included do
    before_create :stamp_created_by
    before_update :stamp_updated_by
  end

  private

  def stamp_created_by
    self.created_by_id = UserActionObserver.current_user&.id if respond_to?(:created_by_id=)
  end

  def stamp_updated_by
    self.updated_by_id = UserActionObserver.current_user&.id if respond_to?(:updated_by_id=)
  end
end
