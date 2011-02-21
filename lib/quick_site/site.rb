require 'net/ssh'
require 'net/scp'
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
      Dir.entries(Settings.site_root).reject{|i| i.match(/^\.|\.git$/) != nil }
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


  # Creates a new Site instance
  def initialize(name)
    @name = name
    setup!
    super
  end
  
    
  # ===================================================
  # Config
  
  # Default config values
  def defaults
    {
      :name         => name,
      :root         => root,
      :domain       => "your-domain.com",
      :email        => "your-email@your-domain.com",
      :host         => Settings.host,
      :user         => Settings.user,
      :port         => Settings.port,
      :password     => Settings.password || "",
      :remote_root  => File.join(Settings.remote_root, "#{dir_name}.com")
    }
  end
  
  # Returns or creates the config object
  def config
    @config ||= {}
  end
    
  # Writes site config to YML file.
  def write_config  
    File.open(config_file, 'w') do |out|
      YAML.dump(defaults.merge(config), out)
    end
    load_config
  end  
  
  # Loads the config.yml into @config 
  def load_config
    return unless File.exists?(config_file)
    obj = YAML::load_file(config_file)
    return unless obj
    @config = obj.symbolize_keys
  end
  
  
  # ===================================================
  # Instance Helpers
  
  # Determines if site is new
  def new?
    !Dir.exists?(root)
  end
  
  # Validates a site instance
  def valid?
    0 < name.length &&
    0 < dir_name.length &&
    !Dir.exists?(root)
  end
  
  # Save a new Site
  def save
    if valid?
      build
    else
      false
    end
  end
  
  # Compares two sites based on their root folders
  def ==(other)
    root == other.root
  end

  
  
  # ===================================================
  # Page Creation
  
  # Creates template unless it exists
  def haml(page)
    page = safe_filename(page)
    return page.to_sym if File.exists?(File.join(view_path, "#{page}.haml"))
    copy_haml("page", page)
    page.to_sym
  end
  
  
  # Add page to git repo
  def add_to_git(file)
    Dir.chdir(@root) do
      execute_quietly("git add #{file}") if File.exists?(file)
    end
  end
  
  
  # ===================================================
  # Remote Actions
  
  # Returns true if site has necessary config to use ssh
  def remote_enabled?
    ssh_enabled = config.include?(:port) && config.include?(:user) && config.include?(:host) && config.include?(:remote_root)
    git_enabled = 0 < system("cd #{@root}; git remote").to_s.strip.length
    Settings.use_git ? ssh_enabled && git_enabled : ssh_enabled
  end
  
  # Returns an object with params for SSH or SCP
  def get_remote_options
    opts = { :port => config[:port] }
    opts[:password] = config[:password] if config.include?(:password)
    opts
  end
  
  # Executes commands in a block with the session as the reciever
  def session(&block)
    return false unless block_given?
    session = Net::SSH.start(config[:host], config[:user], get_remote_options)
    result = yield(session)
    session.close
    result.to_s.strip
  end
  
  # Runs a remote command using the site's config
  def ssh(command)
    session{|ssh| ssh.exec!(command) }
  end
  
  # Copies a local file to the remote server
  def scp(src, dest)
    res = session{|ssh|
      dir = File.dirname(dest)
      unless ssh.exec!("if [ -e #{dir} ]; then echo 'true'; fi").to_s.strip == "true"
        ssh.exec!("mkdir -p #{dir}")
      end
      ssh.scp.upload!(src, dest, :recursive => true)
      ssh.exec!("if [ -e #{dest} ]; then echo 'true'; fi")
    }
    res == 'true'
  end
    
  
  private
  
    # Converts the given filename into a lowercase underscored filename
    def safe_filename(filename)
      filename.downcase.gsub(/[^a-z0-9\_\-\/\.\s]/, '').gsub(/\s+/, '_').gsub(/\/$/, '')
    end
  
    # Sets instance variables
    def setup!
      # setup variables based on name
      @title       = name.titleize
      @dir_name    = safe_filename(name)
      @root        = File.join(Settings.site_root, dir_name)
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
    def build
      mkdir_p view_path
      mkdir_p log_path
      mkdir_p root + "/config"
      copy_template("public")
      copy_template("views")
      write_config
      initialize_git if Settings.use_git
      self
    end
    

    # Creates git repository in root directory and copies .gitignore template
    def initialize_git
      copy_template ".gitignore"
      Dir.chdir(root) do
        execute_quietly("git init; git add .; git commit -a -m 'Initial Commit'")
      end
      
      git = "#{dir_name}.git"
      commands = [
        "rm -r #{config[:remote_root]}",
        "mkdir -p #{config[:remote_root]}",
        "cd #{config[:remote_root]}",
        "git init --bare #{git}",
        "touch #{git}/git-daemon-export-ok",
        "cd #{config[:remote_root]}/#{git}/hooks",
        "mv post-update.sample post-update",
        "chmod a+x post-update"
      ]
      ssh(commands.join(";"))
      
      Dir.chdir(root) do
        execute_quietly("git remote add origin ssh://#{config[:user]}@#{config[:host]}:#{config[:port] || 22}#{config[:remote_root]}/#{dir_name}.git; git push origin master")
      end
    end
    
    
    # Copies a template from the template root to the site's view path 
    def copy_haml(src, dest=src)
      copy_template "#{src}.haml", "views/#{dest}.haml"
    end
    
    
    # Copies a template from the template root to the site's view path 
    def copy_template(src, dest=".")
      dir  = File.expand_path(File.join(root, File.dirname(dest)))
      mkdir_p(dir) unless Dir.exists?(dir)
      cp_r File.join(Settings.template_root, src), File.join(root, dest)
      add_to_git(dest) if Settings.use_git
    end
    
    
    # Redirects $stdout to a log file, executes a command, then returns $stdout to its previous state.
    def execute_quietly(cmd)
      $stdout.reopen(File.join(root, "log/log.txt"), "w")
      system(cmd)
      $stdout.reopen(OUTPUT)
    end

end