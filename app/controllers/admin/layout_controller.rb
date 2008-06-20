class Admin::LayoutController < Admin::AbstractModelController
  model_class Layout
  
  attr_accessor :cache
  
  only_allow_access_to :index, :new, :edit, :remove,
    :when => [:developer, :admin],
    :denied_url => { :controller => 'page', :action => 'index' },
    :denied_message => 'You must have developer privileges to perform this action.'

  def initialize
    super
    @cache = ResponseCache.instance
  end
  
  def save
    saved = super
    model.pages.each { |page| @cache.expire_response(page.url) } if saved
    saved
  end
end