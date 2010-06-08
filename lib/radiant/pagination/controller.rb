module Radiant::Pagination::Controller
  # for inclusion into public-facing controllers

  def configure_pagination
    # unconfigured parameters remain at will_paginate defaults
    # will_paginate controller options are not overridden by tag attribetus 
    WillPaginate::ViewHelpers.pagination_options[:param_name] = Radiant::Config["pagination.param_name"].to_sym unless Radiant::Config["pagination.param_name"].blank?
    WillPaginate::ViewHelpers.pagination_options[:per_page_param_name] = Radiant::Config["pagination.per_page_param_name"].blank? ? :per_page : Radiant::Config["pagination.per_page_param_name"].to_sym

    # will_paginate view options can be overridden by tag attributes
    [:class, :previous_label, :next_label, :inner_window, :outer_window, :separator, :container].each do |opt|
      WillPaginate::ViewHelpers.pagination_options[opt] = Radiant::Config["pagination.#{opt}"] unless Radiant::Config["pagination.#{opt}"].blank?
    end
  end

  def pagination_parameters
    {
      :page => params[WillPaginate::ViewHelpers.pagination_options[:param_name]] || 1, 
      :per_page => params[WillPaginate::ViewHelpers.pagination_options[:per_page_param_name]] || Radiant::Config['pagination.per_page'] || 20
    }
  end

  def self.included(base)
    base.class_eval {
      before_filter :configure_pagination
    }
  end

end





