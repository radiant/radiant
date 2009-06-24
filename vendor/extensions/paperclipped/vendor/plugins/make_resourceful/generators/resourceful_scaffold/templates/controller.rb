class <%= controller_class_name %>Controller < ApplicationController
  make_resourceful do
    actions :all
  end
end
