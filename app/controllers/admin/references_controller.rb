class Admin::ReferencesController < ApplicationController
  def show
    respond_to do |format|
      format.any { render :action => params[:id] }
    end
  end
end
