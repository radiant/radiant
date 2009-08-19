class Admin::ReferencesController < ApplicationController
  def show
    respond_to do |format|
      format.any { render :action => params[:id], :content_type => "text/html", :layout => false }
    end
  end
end
