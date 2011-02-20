class Deployer

  include FileUtils
    
  # Returns the site in deployment
  attr_reader :site
  
  # Returns the unique deployment key
  attr_reader :key
  
  # Returns the name of the tar file
  attr_reader :zip
  
  # Creats a new instance of Deployer with the given site
  #
  def initialize(site)
    @site = site
    @key  = Time.now.strftime('%Y%m%d%H%M%S')
    @zip  = "#{@key}.tar.gz"
    puts zip
    super
  end
  
  # Runs the deploy command chain
  #
  def deploy!
    @compressed = compress
    @uploaded   = upload
    @unzipped   = unzip
    success?
    #false
  end
  
  private
  
    def compress
      puts "compressing"
      chdir @site.root do
        system "tar czf #{@zip} ./public"
      end
      File.exists?(File.join(@site.root, @zip))
    end
    
    def upload
      puts "uploading"
      return false unless Settings.host && Settings.user && Settings.remote_root
      port = Settings.port || 22
      chdir @site.root do
        cmd = "scp -P#{port} #{@zip} #{Settings.user}@#{Settings.host}:#{Settings.remote_root}"
        puts cmd
        system cmd
        
      end
    end
    
    def unzip
      puts "unzipping"
      
    end
    
    def success?
      b = @compressed && @uploaded && @unzipped
      puts "success? #{b}"
      b
    end
  
end