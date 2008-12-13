class Admin::PagesController < Admin::ResourceController
  before_filter :initialize_meta_rows_and_buttons, :only => [:new, :edit, :create, :update]

  def index
    @homepage = Page.find_by_parent_id(nil)
    respond_to do |format|
      format.html
      format.js do
        @level = params[:level].to_i
        @template_name = 'index'
        response.headers['Content-Type'] = 'text/html;charset=utf-8'
        render :action => 'children.html.haml', :layout => false
      end
      format.xml { render :xml => models }
    end
  end

  def new
    self.model = model_class.new_with_defaults(config)
    if params[:page_id].blank?
      self.model.slug = '/'
    end
    response_for :singular
  end

  private
    def model_class
      if params[:page_id]
        Page.find(params[:page_id]).children
      else
        Page
      end
    end

    def announce_saved(message = nil)
      flash[:notice] = message || "Your page has been saved below."
    end

    def announce_pages_removed(count)
      flash[:notice] = if count > 1
        "The pages were successfully removed from the site."
      else
        "The page was successfully removed from the site."
      end
    end

    def initialize_meta_rows_and_buttons
      @buttons_partials ||= []
      @meta ||= []
      @meta << {:field => "slug", :type => "text_field", :args => [{:class => 'textbox', :maxlength => 100}]}
      @meta << {:field => "breadcrumb", :type => "text_field", :args => [{:class => 'textbox', :maxlength => 160}]}
      @meta << {:field => "description", :type => "text_field", :args => [{:class => 'textbox', :maxlength => 200}]}
      @meta << {:field => "keywords", :type => "text_field", :args => [{:class => 'textbox', :maxlength => 200}]}
    end
end
