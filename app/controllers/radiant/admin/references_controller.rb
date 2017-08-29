module Radiant
  class Admin::ReferencesController < ::Radiant::AdminController
    def show
      respond_to do |format|
        format.any { render action: params[:type], content_type: "text/html", layout: false }
      end
    end
  end
end