module Helpers
  
  # Finds a site and uses its paths
  #  
  def site(name)
    site = Site.find(name)
    return redirect "/" unless site
    Settings.set_paths(site)
    site
  end
  
  # Defines helper methods once included into the scope
  #
  def self.included(mod)
  
    helpers do
    
      # Provides simple link_to functionality
      #
      #   = link_to "Home", "/"
      #
      def link_to(text, url, opts={})
        attributes = ""
        url = File.join("/sites/#{@site.name}", url) if @site
        url.sub!(/\/$/, '')
        opts[:class] = (opts[:class] || "").split(" ").push("active").join(" ") if url == request.path.sub(/\/$/, '')
        opts.each { |key, value| attributes << key.to_s << "=\"" << value << "\" "}
        url = '/' if url == ''
        "<a href=\"#{url}\" #{attributes}>#{text}</a>"
      end
      
      # Easily add an image tag
      #
      #   = image_tag("src.png")
      #
      def image_tag(src, opts={})
        attributes = ""
        src = File.join("/sites/#{@site.name}", src) if @site
        opts.each { |key, value| attributes << key.to_s << "=\"" << value << "\" "}
        "<img src=\"#{src}\" #{attributes}/>"
      end
      
      
      # Displays flash messages if they exist.
      #
      #   = flash_helper
      #
      def flash_helper
        return %(<p class="error">#{flash[:error]}</p>) if flash.has?(:error)
        return %(<p class="success">#{flash[:notice]}</p>) if flash.has?(:notice)
      end
      
      
      # Generates a stylesheet link tag for given stylesheets
      #
      #   = stylesheet "home"
      #   = stylesheet "styles", "additional"
      #
      def stylesheet(*args)
        args.collect!{|name|
          %(<link href="/stylesheets/#{name}.css?#{Time.now.to_i}" media="screen" rel="stylesheet" type="text/css"/>)
        }.join("\n")
      end
      
    end
  
  end
  
end

