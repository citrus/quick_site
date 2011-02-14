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
    
    get '/new' do
      haml :new
    end
    
    get '/sites/:name' do
      @site = Site.find(params[:name])
      set_public  @site.public_path
      set :views, @site.view_path
      haml :index
    end
    
    get '/sites/:name/:page' do
      @site = Site.find(params[:name])
      set_public  @site.public_path
      set :views,  @site.view_path
      haml @site.haml(params[:page])
    end
    
    
    # ============================================
    # POST
    
    post '/create' do
      @site = Site.new(params[:name])
      if @site.save
        flash[:success] = "Site created!"
        redirect '/'
      else
        flash[:error] = "Site could not be saved"
        haml :new
      end
    end
  
  end
  
end