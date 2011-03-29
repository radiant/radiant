class Admin::PagesController < Admin::ResourceController
  before_filter :initialize_meta_rows_and_buttons, :only => [:new, :edit, :create, :update]
  before_filter :count_deleted_pages, :only => [:destroy]

  responses do |r|
    r.plural.js do
      @level = params[:level].to_i
      @template_name = 'index'
      self.models = Page.find(params[:page_id]).children.all
      response.headers['Content-Type'] = 'text/html;charset=utf-8'
      render :action => 'children.html.haml', :layout => false
    end
  end

  def index
    @homepage = Page.find_by_parent_id(nil)
    response_for :plural
  end

  def new
    @page = self.model = model_class.new_with_defaults(config)
    assign_page_attributes
    response_for :new
  end
  
  def preview
    render_preview
  rescue => exception
    render :text => exception.message unless @performed_render
  end

  private
    def assign_page_attributes
      if params[:page_id].blank?
        self.model.slug = '/'
      end
      self.model.parent_id = params[:page_id]
    end

    def model_class
      if Page.descendants.any? { |d| d.to_s == params[:page_class] }
        params[:page_class].constantize
      elsif params[:page_id]
        Page.find(params[:page_id]).children
      else
        Page
      end
    end
      
    def render_preview
      Page.transaction do
        PagePart.transaction do
          page_class = Page.descendants.include?(model_class) ? model_class : Page
          if request.referer =~ %r{/admin/pages/(\d+)/edit}
            page = Page.find($1).becomes(page_class)
            page.update_attributes(params[:page])
          else
            page = page_class.new(params[:page])
            page.published_at = page.updated_at = page.created_at = Time.now
            page.parent = Page.find($1) if request.referer =~ %r{/admin/pages/(\d+)/children/new}
          end
          page.process(request,response)
          @performed_render = true
          raise 'Changes not saved!'
        end
      end
    end

    def count_deleted_pages
      @count = model.children.count + 1
    end

    def initialize_meta_rows_and_buttons
      @buttons_partials ||= []
      @meta ||= []
      @meta << {:field => "slug", :type => "text_field", :args => [{:class => 'textbox', :maxlength => 100}]}
      @meta << {:field => "breadcrumb", :type => "text_field", :args => [{:class => 'textbox', :maxlength => 160}]}
    end
end
