module Actions

  SITE_REGEX = Regexp.new("/sites/([a-z0-9\_]+)/?(.*)")

  def self.included(mod)
        
    # ============================================
    # Filters
    
    before do
      matches = request.path.match(SITE_REGEX) || []
      if 0 < matches.length
        @site = site(matches[1])
      else
        Settings.reset_paths
      end
    end
    
    after do
      if Settings.use_git && @site
        @site.add_to_git("views/#{@page}.haml public/#{@page}.html")
      end  
    end
    
    
    # ============================================
    # GET
    
    get '/' do
      @sites = Site.all
      haml :index
    end
    
    get '/sites' do
      redirect '/'
    end
    
    get SITE_REGEX do |name, page|
      @page = 0 < page.length ? page : "index"
      if @page == '_deploy'
        
        @deployer = Deployer.new(@site)
        
        if @deployer.deploy!
          flash[:notice] = 'Success! Your site has been deployed!'
        else
          flash[:error] = 'Your site could not be deployed...'
        end
        redirect '/' 
      else
        template = @site.haml(@page)
        haml template
      end
    end
    
    
    # ============================================
    # POST
    
    post '/create' do
      @site = Site.new(params[:name])
      if @site.save
        flash[:success] = "Site created!"
        redirect @site.path
      else
        @sites = Site.all
        flash[:error] = "Site could not be saved"
        haml :index
      end
    end
  
  end
  
end