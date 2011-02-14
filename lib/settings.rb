module Settings
  
  extend self
  
  # Returns the swappable public path
  #
  #   Settings.public_path
  #
  def public_path
    @public_path ||= @root + "/public"
  end
  
  # Returns the swappable view path
  #
  #   Settings.view_path
  #
  def view_path
    @view_path ||= @root + "/views"
  end
  
  # Create a setting and save its value
  #
  #   Settings.set :foo, "bar"
  #
  def set(name, value)
    instance_variable_set "@#{name.to_s}", value
  end

  # Retrieve a saved setting and throw and error if it doesn't exist.
  #  
  #   Settings.foo # "bar"
  #   Settings.fuz # method missing error
  #
  def method_missing(method, *args, &block)
    val = instance_variable_get "@#{method.to_s}"
    val.nil? ? super : val
  end
  
  # Resets the 'hot-swappable' paths to their defaults
  #  
  #   Settings.reset_paths
  #
  def reset_paths
    @public_path = nil
    @view_path   = nil
  end
  
  # Sets the 'hot-swappable' paths to a site's paths.
  #  
  #   Settings.set_paths(@site)
  #
  def set_paths(site)
    @public_path = site.public_path
    @view_path   = site.view_path
  end
  
  
end