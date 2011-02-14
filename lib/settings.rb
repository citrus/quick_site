module Settings
  
  extend self
  
  # Create a setting and save its value
  #
  #   settings.set :foo, "bar"
  #
  def set(name, value)
    instance_variable_set "@#{name.to_s}", value
  end

  # Retrieve a saved setting and throw and error if it doesn't exist.
  #  
  #   settings.foo # "bar"
  #   settings.fuz # method missing error
  #
  def method_missing(method, *args, &block)
    val = instance_variable_get "@#{method.to_s}"
    val.nil? ? super : val
  end
  
end