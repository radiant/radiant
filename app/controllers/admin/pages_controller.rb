class Admin::PagesController < Admin::AbstractModelController
  before_filter :initialize_meta_rows_and_buttons, :only => [:new, :edit]

  def index
    @homepage = Page.find_by_parent_id(nil)
    respond_to do |format|
      format.html
      format.js do
        @level = params[:level].to_i
        response.headers['Content-Type'] = 'text/html;charset=utf-8'
        render :template => 'children.html.haml', :layout => false 
      end
      format.xml { render :xml => models }
    end
  end

  def new
    self.model = Page.new_with_defaults(config)
    super
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
end
