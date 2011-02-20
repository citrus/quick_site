require 'fileutils'
require 'active_support/inflector'

OUTPUT = STDOUT.dup        
        
class Site
  
  include FileUtils
  
  class << self
  
    # Returns an array of sites (folders) in the site root folder.
    #
    #   Site.all # ["test", "sample", ...]
    #
    def all
      return [] unless Dir.exists?(Settings.site_root)
      Dir.entries(Settings.site_root).reject{|i| i.match(/^\./) != nil }
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
  
  # The name of the site
  attr_reader :name
  
  # Browser title
  attr_reader :title
  
  # Name of the site's directory
  attr_reader :dir_name
  
  # Full path to site including dir_name
  attr_reader :root
  
  # Web path to the site (/sites/sample_site)
  attr_reader :path
  
  # Path to the site's public directory
  attr_reader :public_path
  
  # Path to the site's view directory
  attr_reader :view_path
  
  # Path to the site's log directory
  attr_reader :log_path
  
  # Path to the site's config file
  attr_reader :config_file
  
  # YML parsed site config hash
  attr_reader :config
    
  ## The name of the newly saved page
  #attr_reader :new_page
    
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
  
  # A helper for new pages
  #
  def new_page?
    @new_page
  end
  
  # Add page to git repo
  #
  def update_git
    Dir.chdir(@root) do
      execute_quietly("git add views/#{@new_page}.haml public/#{@new_page}.html")
    end
  end
  
  # Creates template unless it exists
  #
  def haml(name)
    @new_page = false
    name = safe_filename(name)
    return name.to_sym if File.exists?(File.join(@view_path, "#{name}.haml"))
    copy_haml("page", name)
    @new_page = name
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
      name.downcase.gsub(/[^a-z0-9\_\-\/\.\s]/, '').gsub(/\s+/, '_').gsub(/\/$/, '')
    end
  
    # Sets instance variables
    #
    def setup!
      # setup variables based on name
      @title       = @name.titleize
      @dir_name    = safe_filename(@name)
      @root        = File.join(Settings.site_root, @dir_name)
      @path        = "/sites/#{@dir_name}"
      @view_path   = @root + "/views"
      @log_path    = @root + "/log"
      @public_path = @root + "/public"
      @config_file = @root + "/config/application.yml"
      # load config if it exists
      load_config
      self
    end
    
    
    # Build site structure
    #
    def build
      mkdir_p @view_path
      mkdir_p @log_path
      mkdir_p @root + "/config"
      copy_template("public")
      copy_template("views")
      write_config
      initialize_git if Settings.use_git
      self
    end 
    
    ## Creates a templated page and checks it into git
    ##
    #def build_page(name)
    #  copy_haml("page", name)
    #  #Dir.chdir(@root) do
    #  #  execute_quietly("git add views/#{name}.haml")
    #  #end
    #  true
    #end


    # Creates git repository in root directory and copies .gitignore template
    #
    def initialize_git
      copy_template ".gitignore"
      Dir.chdir(@root) do
        execute_quietly("git init; git add .; git commit -a -m 'Initial Commit'")
      end
    end
    
    
    # Applies site variables to a mustache template and writes it to the site directory
    #
    def mustache_copy(template)
      #puts template.inspect
      temp = File.join(Settings.template_root, "#{template}.mustache")
      dest = File.join(@root, template)
      File.open(dest, 'w') { |file|
        file.write(Mustache.render(File.read(temp), :name => dir_name))
      }
    end
    
    # Copies a template from the template root to the site's view path 
    #
    def copy_haml(name, to=name)
      copy_template "#{name}.haml", "views/#{to}.haml"
    end
    
    
    # Copies a template from the template root to the site's view path 
    #
    def copy_template(name, to=".")
      dest = File.expand_path(File.join(@root, File.dirname(to)))
      mkdir_p(dest) unless Dir.exists?(dest)
      cp_r File.join(Settings.template_root, name), File.join(@root, to)
    end
    
    
    # Redirects $stdout to a log file, executes a command, then returns $stdout to its previous state.
    #
    def execute_quietly(cmd)
      $stdout.reopen("log/log.txt", "w")
      system(cmd)
      $stdout.reopen(OUTPUT)
    end

end