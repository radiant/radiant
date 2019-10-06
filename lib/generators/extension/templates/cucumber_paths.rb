module NavigationHelpers
  
  # Extend the standard PathMatchers with your own paths
  # to be used in your features.
  # 
  # The keys and values here may be used in your standard web steps
  # Using:
  #
  #   When I go to the "<%= file_name %>" admin page
  # 
  # would direct the request to the path you provide in the value:
  # 
  #   admin_<%= file_name %>_path
  # 
  PathMatchers = {} unless defined?(PathMatchers)
  PathMatchers.merge!({
    # /<%= file_name %>/i => 'admin_<%= file_name %>_path'
  })
  
end

World(NavigationHelpers)