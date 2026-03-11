# Create admin user
admin = User.find_or_initialize_by(login: "admin")
admin.assign_attributes(
  name: "Administrator",
  login: "admin",
  password: "radiant",
  password_confirmation: "radiant",
  admin: true
)
admin.save!
puts "Admin user created (login: admin, password: radiant)"

# Set current user for action stamps
UserActionObserver.current_user = admin

# Create default configuration
{
  "admin.title"           => "Radiant CMS",
  "admin.subtitle"        => "Publishing for Small Teams",
  "defaults.page.parts"   => "body, extended",
  "defaults.page.status"  => "Draft",
  "defaults.page.filter"  => "",
  "defaults.page.fields"  => "Keywords, Description",
  "session_timeout"        => 2.weeks.to_i.to_s,
  "default_locale"         => "en",
}.each do |key, value|
  config = Radiant::Config.find_or_initialize_by(key: key)
  config[:value] = value.to_s
  config.save!
end
puts "Default configuration created"

# Create root page
unless Page.find_by(parent_id: nil)
  homepage = Page.new(
    title: "Home",
    slug: "/",
    breadcrumb: "Home",
    status_id: 100, # Published
    class_name: "",
    virtual: false
  )
  homepage.parts.build(name: "body", content: "<h1>Welcome to Radiant</h1>\n<p>This is the homepage.</p>", filter_id: "")
  homepage.parts.build(name: "extended", content: "", filter_id: "")
  homepage.save!
  puts "Root page created"
end
