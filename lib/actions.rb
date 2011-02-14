module Actions

  def self.included(mod)
        
    # ============================================
    # Filters
    
    before do
      matches = request.path.match(/\/sites\/([a-z0-9\_]+)/) || []
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
    
    get '/sites/:name' do
      haml :index
    end
    
    get '/sites/:name/:page' do
      haml @site.haml(params[:page])
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