module Settings
  
  extend self
  
  
  # A Hash to store values 
  #
  def settings
    @settings ||= {}
  end
  alias :all :settings
  
  # Returns the swappable public path
  #
  #   Settings.public_path
  #
  def public_path
    @public_path ||= root + "/public"
  end
  
  # Returns the swappable view path
  #
  #   Settings.view_path
  #
  def view_path
    @view_path ||= root + "/views"
  end
  
  # Create a setting and save its value
  #
  #   Settings.set :foo, "bar"
  #   Settings.set :foo => "bar"
  #   Settings.set :foo => "bar", :beer => "good"
  #
  def set(setting, value=setting)
    case setting.class.to_s
      when 'Hash'
        settings.merge!(value)
      when 'String', 'Symbol'
        settings[setting.to_sym] = value
      else
        raise ArgumentError, "setting must be a symbol, string or hash"
    end
  end
  
  
  # Finds a setting and returns its value
  #
  #   Settings.get :foo  #=> "bar"
  #
  def get(name)
    send(name)
  end

  # Retrieve a saved setting or return false if it doesn't exist.
  #
  #   Settings.foo #=> "bar"
  #   Settings.fuz #=> method missing error
  #
  def method_missing(method, *args, &block)
    val = settings[method] #instance_variable_get "@#{method.to_s}"
    val.nil? ? false : val
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