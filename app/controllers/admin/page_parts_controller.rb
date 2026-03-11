class Admin::PagePartsController < Admin::ResourceController
  def create
    self.model.attributes = page_part_params
    @controller_name = 'page'
    @template_name = 'edit'
    render :partial => "page_part", :object => model,
      :locals => {:page_part_counter => params[:index].to_i}
  end

  private

  def page_part_params
    params.require(:page_part).permit(:name, :filter_id, :content)
  end
end
