module Helpers

  def set_public(dir)
    return true if dir == settings.public
    FileUtils.rm_r settings.public if File.symlink?(settings.public)
    FileUtils.mv settings.public, settings.public + ".bak" if Dir.exists?(settings.public)
    FileUtils.ln_s dir, settings.public
  end
  
  def site(name)
    @site = Site.find(name)
    return redirect "/" unless @site
    Settings.set_paths(@site)
    @site
  end
  
  # ============================================
  # Helpers
  
  def self.included(mod)
  
    helpers do
    
      def link_to(text, url, opts={})
        attributes = ""
        url = File.join("/sites/#{@site.name}", url) if @site
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
  
  end
  
end

