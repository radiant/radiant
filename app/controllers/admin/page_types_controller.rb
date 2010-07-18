class Admin::PageTypesController < ApplicationController
  def index
    @page = Page.find(params[:page_id])
    @options = page_types
    render :layout => false
  end

  private

    def page_types
      Page.descendants.sort_by(&:name)
    end
end