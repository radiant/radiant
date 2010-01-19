module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the home\s?page/
      '/'
    
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))
    when /the homepage/
      root_path
    when /sitemap/i
      admin_pages_path
    when /login/i
      login_path
    when /preferences/i
      edit_admin_preferences_path
    when /snippets/i
      admin_snippets_path
    when /login/i
      login_path
    when /users/
      admin_users_path
    when /admin:(.*) as xml/i
      "/admin/#{$1}.xml"
    when /admin:(.*)/i
      "/admin/#{$1}"
    when "my-child"
      "/my-child"
    when "page:parent/child/grandchild/great-grandchild"
      "/parent/child/grandchild/great-grandchild"
    when "page:first"
      "/first"
    
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
