module TestHelperDirective
  # Class method for test helpers
  def test_helper(*names)
    names.each do |name|
      name = name.to_s
      name = $1 if name =~ /^(.+)_test_helper$/i
      name = name.singularize
      first_time = true
      begin
        constant = (name.camelize + 'TestHelper').constantize
        self.send(:include, constant)
      rescue NameError
        if first_time
          filename = Rails.root + 'test/helpers' + "#{name}_test_helper"
          require filename
          first_time = false
          retry
        else
          raise
        end
      end
    end
  end
  alias :test_helpers :test_helper
end

RSpec.configure do |config|
  config.extend TestHelperDirective
end
