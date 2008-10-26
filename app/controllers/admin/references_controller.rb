class Admin::ReferencesController < ApplicationController
  def show
    render :action => params[:id]
  end
end
