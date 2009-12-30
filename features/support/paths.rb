module NavigationHelpers
  def path_to(page_name)
    case page_name
    
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
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
