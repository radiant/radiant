module InterfaceAdditions
  def self.included(base)
    base.class_eval {
      before_filter :add_hide_page, :only => [:edit, :new]
      include InstanceMethods
    }
  end
  module InstanceMethods
    def add_hide_page
      @meta << {:field => "hide_in_menu", :type => "check_box", :args => [{:class => 'checkbox'}]}
    end
  end
end