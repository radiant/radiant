module NavigationHelpers
  
  # This hash can be extended with regular expressions
  # and path values
  #
  #   PathMatchers[/styles/i] = 'admin_styles_path'
  #
  PathMatchers = {} unless defined?(PathMatchers)
  
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name, format=nil)
    PathMatchers.each do |path_matcher, value|
      if path_matcher =~ normalize_page_name(page_name)
        return send(value, {:format => format})
      end
    end
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
    when /configuration/i
      admin_configuration_path(:format => format)
    when /extensions/i
      admin_extensions_path(:format => format)
    when /export/i
      export_path(:format => format)
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
  
  def normalize_page_name(page_name)
    page_name.gsub(/^["']+(.*?)["']+$/,'\1')
  end
end

World(NavigationHelpers)
