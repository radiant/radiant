class Admin::PageController < Admin::AbstractModelController
  model_class Page
  before_filter :initialize_meta_rows_and_buttons, :only => [:new, :edit]
  attr_accessor :cache

  def initialize
    super
    @cache = ResponseCache.instance
  end
  
  def index
    @homepage = Page.find_by_parent_id(nil)
  end
  
  def new
    @page = request.get? ? Page.new_with_defaults(config) : Page.new
    @page.slug = params[:slug]
    @page.breadcrumb = params[:breadcrumb]
    @page.parent = Page.find_by_id(params[:parent_id])
    render :action => :edit if handle_new_or_edit_post
  end

  def edit
    @page = Page.find(params[:id])
    handle_new_or_edit_post
  end

  def remove
    @page = Page.find(params[:id])
    if request.post?
      announce_pages_removed(@page.children.count + 1)
      @page.destroy
      redirect_to page_index_url
    end
  end

  def add_part
    part = PagePart.new(params[:part])
    @index = params[:index].to_i if params[:index]
    render(:partial => 'part', :object => part, :layout => false)
  end

  def children
    @parent = Page.find(params[:id])
    @level = params[:level].to_i
    response.headers['Content-Type'] = 'text/html;charset=utf-8'
    render(:layout => false)
  end

  def tag_reference
    @class_name = params[:class_name]
    @display_name = @class_name.constantize.display_name
  end
  
  def filter_reference
    @filter_name = params[:filter_name]
    @display_name = (@filter_name + "Filter").constantize.filter_name rescue "&lt;none&gt;"
  end
  
  private
  
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
    
    def announce_cache_cleared
      flash[:notice] = "The page cache was successfully cleared."
    end
    
    def initialize_meta_rows_and_buttons
      @buttons_partials ||= []
      @meta ||= []
      @meta << {:field => "slug", :type => "text_field", :args => [{:class => 'textbox', :maxlength => 100}]}
      @meta << {:field => "breadcrumb", :type => "text_field", :args => [{:class => 'textbox', :maxlength => 160}]}
      @meta << {:field => "description", :type => "text_field", :args => [{:class => 'textbox', :maxlength => 200}]}
      @meta << {:field => "keywords", :type => "text_field", :args => [{:class => 'textbox', :maxlength => 200}]}
    end
    
    def save
      parts = @page.parts
      parts_to_update = {}
      (params[:part]||{}).each {|k,v| parts_to_update[v[:name]] = v }
      
      parts_to_remove = []
      @page.parts.each do |part|
        if(attrs = parts_to_update.delete(part.name))
          part.attributes = part.attributes.merge(attrs)
        else
          parts_to_remove << part
        end
      end
      parts_to_update.values.each do |attrs|
        @page.parts.build(attrs)
      end
      if result = @page.save
        new_parts = @page.parts - parts_to_remove
        new_parts.each { |part| part.save }
        @page.parts = new_parts
      end
      result
    end
    
    def clear_model_cache
      @cache.clear
    end
end
