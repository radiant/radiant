module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case normalize_page_name(page_name)
    when /^\/(.*)/
      $1
    when /the home\s?page/
      '/'
    when /the (\S+) (|admin )page as (\w+)/
      path_to($1, $3)
    when /the (\S+) ($:|admin )page/
      path_to($1)
    when /first/
      '/first'
    when /new child/
      '/my-child'
    when /great-grandchild/
      '/parent/child/grandchild/great-grandchild'
    when /sitemap/i
      admin_pages_path(:format => format)
    when /login/i
      login_path(:format => format)
    when /preferences/i
      admin_preferences_path(:format => format)
    when /snippets/i
      admin_snippets_path(:format => format)
    when /login/i
      login_path(:format => format)
    when /users/i
      admin_users_path(:format => format)
    when /pages/i
      admin_pages_path(:format => format)
    when /layouts/i
      admin_layouts_path(:format => format)
    when /snippets/i
      admin_snippets_path(:format => format)
    when /users/i
      admin_users_path(:format => format)
    when /extensions/i
      admin_extensions_path(:format => format)
    when /export/i
      export_path(:format => format)
    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
  
  def normalize_page_name(page_name)
    page_name.gsub(/^["']+(.*?)["']+$/,'\1')
  end
end

World(NavigationHelpers)
