
module Sinatra 
  
  ##
  # Sinatra::Templates
  # 
  # Monkey-patches the private <tt>#render</tt> method, 
  # in order to support 'auto-magic' cache functionality.
  # 
  # 
  module Templates 
    
    private
      
      def render(engine, data, options={}, locals={}, &block)
        # merge app-level options
        options = settings.send(engine).merge(options) if settings.respond_to?(engine)
        options[:outvar]           ||= '@_out_buf'
        options[:default_encoding] ||= settings.default_encoding
    
        # extract generic options
        locals          = options.delete(:locals) || locals         || {}
        views           = options.delete(:views)  || settings.views || "./views"
        @default_layout = :layout if @default_layout.nil?
        layout          = options.delete(:layout)
        eat_errors      = layout.nil?
        layout          = @default_layout if layout.nil? or layout == true
        content_type    = options.delete(:content_type)  || options.delete(:default_content_type)
        layout_engine   = options.delete(:layout_engine) || engine
    
        # compile and render template
        layout_was      = @default_layout
        @default_layout = false
        template        = compile_template(engine, data, options, views)
        output          = template.render(self, locals, &block)
        @default_layout = layout_was
    
        # render layout
        if layout
          options = options.merge(:views => views, :layout => false, :eat_errors => eat_errors)
          catch(:layout_missing) { output = render(layout_engine, layout, options, locals) { output }}
          File.open(File.join(Settings.public_path, "#{data}.html"), "w") {|file| file.write(output.gsub(/[\n\r]*/, '').gsub(/\s+/, ' ')) }
        end
    
        output.extend(ContentTyped).content_type = content_type if content_type
        output
      end
      
  end #/module Templates
  
end #/module Sinatra 
