module Actions

  SITE_REGEX = Regexp.new("/sites/([a-z0-9\_]+)/?(.*)")

  def self.included(mod)
        
    # ============================================
    # Filters
    
    before do
      matches = request.path.match(SITE_REGEX) || []
      if 0 < matches.length
        site(matches[1])
      else
        Settings.reset_paths
      end
    end
    
    
    # ============================================
    # GET
    
    get '/' do
      @sites = Site.all
      haml :index
    end
    
    get SITE_REGEX do |name, page|
      @page = 0 < page.length ? page : "index"
      haml @site.haml(@page)
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