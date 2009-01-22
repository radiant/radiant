# Undefined unneeded tasks in instance mode
unless Radiant.app?
  def undefine_task(*names)
    app = Rake.application
    tasks = app.instance_variable_get('@tasks')
    names.flatten.each { |name| tasks.delete(name) }
  end
  
  undefine_task %w(
    radiant:clobber_package 
    radiant:install_gem
    radiant:package
    radiant:release
    radiant:repackage
    radiant:uninstall_gem
    rails:freeze:edge
    rails:freeze:gems
    rails:unfreeze
    rails:update
    rails:update:configs
    rails:update:javascripts
    rails:update:scripts
  )
end