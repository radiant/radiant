class Admin::PageTypesController < ApplicationController
  def index
    @page = Page.find(params[:page_id])
    @options = Page.descendants.sort_by(&:name)
    render :layout => false
  end
end