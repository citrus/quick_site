class Deployer

  include FileUtils
    
  # Returns the site in deployment
  attr_reader :site
  
  # Returns the unique deployment key
  attr_reader :key
  
  # Returns the name of the tar file
  attr_reader :tar
  
  # Creats a new instance of Deployer with the given site
  def initialize(site)
    @site = site
    @key  = Time.now.strftime('%Y%m%d%H%M%S')
    @tar  = "#{@key}.tar.gz"
    super
  end
  
  
  # Runs the deploy command chain
  def deploy!
    if Settings.use_git
      #@commit_and_push  
      
      #ssh("cd @site.config[:remote_root]; git pull origin master")
      
      return true
    else
      # deploy via tar, ssh && scp
      @compressed = compress
      return false unless @compressed
      @uploaded   = upload
      return false unless @uploaded
      @unzipped   = unzip
      return false unless @unzipped
    end
    @symlinked  = symlink
    success?
  end
  
  # Checks is a file exists on the server 
  def remote_exists?(dir)
    @site.ssh("if [ -e #{dir} ]; then echo 'true'; else echo 'false'; fi").strip == 'true'
  end
  
  
  private
  
    # Writes site's public folder to an archive
    def compress
      chdir @site.root do
        system "tar czf #{@tar} ./public"
      end
      File.exists?(File.join(@site.root, @tar))
    end
    
    
    # Uploads archive to the server
    def upload
      return false unless @site.remote_enabled?
      release = File.join(@site.config[:remote_root], 'releases', @key)
      tar = File.join(release, @tar)
      @site.ssh("mkdir -p #{release}/log") unless remote_exists?(release)
      @site.scp(File.join(@site.root, @tar), tar)
    end
    
    
    # Untars archive on the server
    def unzip
      return false unless @site.remote_enabled?
      releases = File.join(@site.config[:remote_root], 'releases')
      @site.ssh("cd #{releases}/#{@key}; tar xzf #{@tar}; rm #{@tar}")
      remote_exists?(File.join(releases, @key, 'public'))
    end
    
    # Symlinks the current folder to the last release
    def symlink
      current = File.join(@site.config[:remote_root], 'current')   
      release = File.join(@site.config[:remote_root], 'releases', @key)
      @site.ssh("rm -rf #{current}") if remote_exists?(current)
      @site.ssh("ln -s #{release} #{current}")
      remote_exists?(current)
    end
    
    # Returns true if release has been compressed, uploaded and unzipped
    def success?
      @compressed && @uploaded && @unzipped && @symlinked
    end
    
end