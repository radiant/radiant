class Admin::PagePartsController < Admin::ResourceController
  def create
    self.model.attributes = params[model_symbol]
    @controller_name = 'page'
    @template_name = 'edit'
    render :partial => "page_part", :object => model,
      :locals => {:page_part_counter => params[:index].to_i}
  end
end