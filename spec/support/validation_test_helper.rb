module ValidationTestHelper
  def assert_valid(field, *values)
    __model_check__
    values.flatten.each do |value|
      o = __setup_model__(field, value)
      if o.valid?
        assert_block { true }
      else
        messages = [o.errors[field]].flatten
        assert_block("unexpected invalid field <#{o.class}##{field}>, value: <#{value.inspect}>, errors: <#{o.errors[field].inspect}>.") { false }
      end
    end
  end

  def assert_invalid(field, message, *values)
    __model_check__
    values.flatten.each do |value|
      o = __setup_model__(field, value)
      if o.valid?
        assert_block("field <#{o.class}##{field}> should be invalid for value <#{value.inspect}> with message <#{message.inspect}>") { false }
      else
        messages = [o.errors[field]].flatten
        assert_block("field <#{o.class}##{field}> with value <#{value.inspect}> expected validation error <#{message.inspect}>, but got errors <#{messages.inspect}>") { messages.include?(message) }
      end
    end
  end

  def __model_check__
    raise "@model must be assigned in order to use validation assertions" if @model.nil?

    o = @model.class.new(@model.attributes)
    raise "@model must be valid before calling a validation assertion, instead @model contained the following errors #{o.errors.messages}" unless o.valid?
  end

  def __copy_attributes__(first, second)
    second.instance_variable_set('@attributes', first.attributes.dup)
    second
  end

  def __setup_model__(field, value)
    o = @model.class.new(@model.attributes)
    attributes = o.instance_variable_get('@attributes')
    o.instance_variable_set('@attributes', attributes.dup)
    o.send("#{field}=", value)
    o
  end
end
