module ExtensionTagTestHelper
  def assert_global_tag_defined(name)
    assert Page.instance_methods.include?("tag:#{name}"), "Global tag #{name} does not exist."
  end
  
  def assert_global_tag_module(mod)
    assert Page.included_modules.include?(mod), "Tag module #{mod} is a global tag module."
  end
  
  def assert_tag_defined(page_model, name)
    assert page_model.instance_methods.include?("tag:#{name}"), "Tag #{name} does not exist in #{page_model}."
  end
  
  def assert_tag_module(page_model, mod)
    assert page_model.included_modules.include?(mod), "Tag module #{mod} is not included in #{page_model}."
  end
end
