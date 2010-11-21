class Admin::PageFieldsController < Admin::ResourceController
  def create
    self.model = PageField.new(params[model_symbol])
    @controller_name = 'page'
    @template_name = 'edit'
    render :partial => "page_field", :object => model,
      :locals => { :page_field_counter => params[:page_field_counter].to_i}
  end
end
