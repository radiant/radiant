class Admin::LayoutsController < Admin::ResourceController
  paginate_models
  require_role :designer, :admin,
    denied_url: {controller: "admin/pages", action: "index"},
    denied_message: "You must have designer privileges to perform this action."

end
