require 'fileutils'
require 'active_support/inflector'

class Site
  
  include FileUtils
  
  class << self
  
    # Returns an array of sites (folders) in the site root folder.
    #
    #   Site.all # ["test", "sample", ...]
    #
    def all
      return [] unless Dir.exists?(settings.site_root)
      Dir.entries(settings.site_root).reject{|i| i.match(/^\./) != nil }
    end
    
    # Finds a site's root folder, then creates a new instance of Site and loads it's config. 
    #
    #   Site.find("test") # #<Site:0x00 @name="test"...
    #
    def find(name)
      site = Site.new(name)
      return false if site.new?
      site
    end
    
  end
    
  attr_reader :name, :title, :dir_name, :root, :path, :view_path, :public_path, :config_file, :config
    
    
  # Creates a new Site instance
  #
  def initialize(name)
    @name = name
    setup!
    super
  end
  
  
  # Save a new Site
  #
  def save
    if valid?
      build
    else
      false
    end
  end
  
  
  # Determines if site is new
  #
  def new?
    !Dir.exists?(@root)
  end
  
  
  # Validates a site instance
  #
  def valid?
    0 < @name.length &&
    0 < @dir_name.length &&
    !Dir.exists?(@root)
  end
  
  
  # Creates template unless it exists
  #
  def haml(name)
    name = safe_filename(name)
    return name.to_sym if File.exists?(File.join(@view_path, "#{name}.haml"))
    copy_template("page", name)
    name.to_sym
  end
  
    
  # Writes site config to YML file.
  #
  def write_config
    File.open(@config_file, 'w') do |out|
      YAML.dump({
        "name"   => @name,
        "root"   => @root,
        "domain" => "your-domain.com",
        "email"  => "your-email@your-domain.com"
      }, out )
    end
    load_config
  end
  
  
  # Loads the config.yml into @config 
  #
  def load_config
    return false unless File.exists?(@config_file)
    @config = YAML::load_file(@config_file)
  end
  
  # Compares two sites based on their root folders
  #
  def ==(other)
    @root == other.root
  end
  
  
  private
  
    # Converts the given name into a lowercase underscored filename
    #
    def safe_filename(name)
      name.parameterize.gsub("-", "_")
    end
  
    # Sets instance variables
    #
    def setup!
      # setup variables based on name
      @title       = @name.titleize
      @dir_name    = safe_filename(@name)
      @root        = File.join(settings.site_root, @dir_name)
      @path        = "/sites/#{@dir_name}"
      @view_path   = @root + "/views"
      @public_path = @root + "/public"
      @config_file = @root + "/config.yml"
      # load config if it exists
      load_config
      self
    end
    
    
    # Build site structure
    #
    def build
      mkdir_p @view_path
      cp_r File.join(settings.template_root, "public"), @root
      cp_r File.join(settings.template_root, "views"), @root
      write_config
      self
    end 
    
    # Copies a template from the template root to the site's view path 
    #
    def copy_template(name, to=name)
      cp File.join(settings.template_root, "#{name}.haml"), File.join(@view_path, "#{to}.haml")
    end

   
end