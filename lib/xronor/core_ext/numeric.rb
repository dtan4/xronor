class Numeric
  def respond_to?(method, include_private = false)
    super || Xronor::DSL::NumericSeconds.public_method_defined?(method)
  end

  def method_missing(method, *args, &block)
    if Xronor::DSL::NumericSeconds.public_method_defined?(method)
      Xronor::DSL::NumericSeconds.new(self).send(method)
    else
      super
    end
  end
end
