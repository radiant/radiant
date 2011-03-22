class Admin::ExportController < ApplicationController
  def export
    render :text => Radiant::Exporter.export(params[:type] || 'yaml'), :content_type => "text/yaml"
  end
end
