#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'rack-flash'
require 'sinatra'
require 'active_support/inflector'

use Rack::Session::Cookie
use Rack::Flash


set :root, File.dirname(__FILE__)
set :public, settings.root + "/public"
set :publik, settings.root + "/publik"
set :site_root, settings.root + "/sites"
set :template_root, settings.root + "/templates"


def set_public(dir)
  FileUtils.rm_r settings.public if File.exists?(settings.public)
  FileUtils.ln_s dir, settings.public
end


class Site
  
  include FileUtils
  
  class << self
  
    # Returns an array of sites (folders) in the site root folder.
    #
    def all
      return [] unless Dir.exists?(settings.site_root)
      Dir.entries(settings.site_root).reject{|i| i.match(/^\./) != nil }
    end
    
    # Finds a site's root folder, then creates a new instance of Site and loads it's config. 
    #
    def find(name)
      site = Site.new(name)
      return false if site.new?
      site
    end
    
  end
    
  attr_reader :name, :dir_name, :root, :view_path, :public_path, :config_file, :config
    
    
  # Create a new Site instance
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
    puts "new! #{@dir_name}"
    !Dir.exists?(@root)
  end
  
  
    
  # Validates a site instance
  #
  def valid?
    0 < @name.length &&
    0 < @dir_name.length &&
    !Dir.exists?(@root)
  end
  
  
  # Creates template unless it exists
  #
  def haml(name)
    return name.to_sym if File.exists?(File.join(@view_path, "#{name}.haml"))
    copy_template("page", name)
    name
  end
  
    
  # Writes site config to YML file.
  #
  def write_config
    File.open(@config_file, 'w') do |out|
      YAML.dump({
        "name"   => @name,
        "domain" => "your-domain.com",
        "email"  => "your-email@your-domain.com",
        "pages"  => ["home","about","contact"]
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
  
  
  private
  
  
    # Sets instance variables
    #
    def setup!
      # setup variables based on name
      @dir_name    = @name.parameterize.gsub("-", "_")
      @root        = File.join(settings.site_root, @dir_name)
      @view_path   = @root + "/views"
      @public_path = @root + "/public"
      @config_file = @root + "/config.yml"
      # load config if it exists
      load_config
      puts @config.inspect
      self
    end
    
    
    # Build site structure
    #
    def build
      puts "----"
      puts "BUILDING SITE #{@name} - #{@dir_name}"
      puts "in dir_name: #{@root}"
      
      #mkdir_p @root
      mkdir_p @view_path
      cp_r File.join(settings.template_root, "public"), @root
      
      copy_template("layout")
      copy_template("index")
      
      write_config
      true
    end 
    
    def copy_template(name, to=name)
      cp File.join(settings.template_root, "#{name}.haml"), File.join(@view_path, "#{to}.haml")
    end
    
  
  
end



# ============================================
# Helpers

helpers do

  def link_to(text, url, opts={})
    attributes = ""
    opts.each { |key, value| attributes << key.to_s << "=\"" << value << "\" "}
    "<a href=\"#{url}\" #{attributes}>#{text}</a>"
  end
  
  def flash_helper
    return %(<p class="error">#{flash[:error]}</p>) if flash.has?(:error)
    return %(<p class="success">#{flash[:notice]}</p>) if flash.has?(:notice)
  end
  
  def stylesheet(name)
    %(<link href="/stylesheets/#{name}.css?#{Time.now.to_i}" media="screen" rel="stylesheet" type="text/css"/>)
  end
  
end




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
  haml @site.haml(params[:page]) #:index
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
