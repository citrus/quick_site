module Helpers

  def set_public(dir)
    FileUtils.rm_r settings.public if File.exists?(settings.public)
    FileUtils.ln_s dir, settings.public
  end
  
  # ============================================
  # Helpers
  
  def self.included(mod)
  
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
  
  end
  
end

