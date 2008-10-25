class Admin::PagePartsController < Admin::ResourceController
  def new
    @controller_name = 'page'
    @action_name = 'edit'
    render :partial => "page_part", :object => model,
      :locals => {:index => params[:index].to_i}
  end
end