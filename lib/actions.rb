module Actions


  
  def self.included(mod)
  
      
    # ============================================
    # Filters
    
    before do
      set_public  settings.publik
      set :views, settings.root + "/views"
    end
    
    # ============================================
    # GET
    
    
    get '/' do
      @sites = Site.all
      haml :index
    end
    
    #get '/new' do
    #  haml :new
    #end
    
    get '/sites/:name' do
      site(params[:name])
      haml :index
    end
    
    get '/sites/:name/:page' do
      site(params[:name])
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