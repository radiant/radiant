class Admin::ExportController < ApplicationController
  def yaml
    render :text => Radiant::Exporter.export, :content_type => "text/yaml"
  end
end
