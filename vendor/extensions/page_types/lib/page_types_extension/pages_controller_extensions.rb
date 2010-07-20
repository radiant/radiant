module PageTypesExtension::PagesControllerExtensions
  def self.included(base)
    base.class_eval do
      responses.new.default do
        initialize_page_class
      end
    end
  end

  def initialize_page_class
    if params[:page_class] && params[:page_class].constantize <= Page
      self.model.class_name = params[:page_class]
    end
  rescue NameError => e
    logger.warn "Wrong page class given in Pages#new: #{e.message}"
  end
end