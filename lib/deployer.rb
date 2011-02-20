class Deployer

  include FileUtils
    
  # Returns the site in deployment
  attr_reader :site
  
  # Returns the unique deployment key
  attr_reader :key
  
  # Creats a new instance of Deployer with the given site
  #
  def initialize(site)
    @site = site
    @key  = Time.now.strftime('%Y%m%d%H%M%S')
  end
  
  # Runs the deploy command chain
  #
  def deploy!
    
    # compress public folder
    
    # upload
    
    # unzip
    
    compress
    upload
    unzip
    
    
    false
    
  end
  
  private
  
    def compress
      puts "compressing"
      chdir @site.root do
        cmd = "tar czf #{@site.dir_name}-#{@key}.tar.gz ./public" 
        puts cmd
        system cmd
      end
    end
    
    def upload
      puts "uploading"
      
    end
    
    def unzip
      puts "unzipping"
      
    end
  
end