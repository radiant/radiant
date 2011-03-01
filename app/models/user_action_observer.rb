class UserActionObserver < ActiveRecord::Observer
  observe User, Page, Layout, Snippet
  
  def self.current_user=(user)
    Thread.current[:current_user] = user
  end
  
  def self.current_user
    Thread.current[:current_user]
  end
  
  def before_create(model)
    model.created_by = self.class.current_user
  end
  
  def before_update(model)
    model.updated_by = self.class.current_user
  end
end