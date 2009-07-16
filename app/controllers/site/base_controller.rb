class Site::BaseController < ApplicationController

  extend SiteIntrospector::ControllerClassMethods

  before_filter :setup_site_context
  before_filter :setup_site_helpers
  layout :site_layout

  protected

  def setup_site_context
    if not @site = Site.find_by_name(params[:site_name])
      raise ActiveRecord::RecordNotFound.new("Site '#{params[:site_name]}' not found") 
    end
  end

  def setup_site_helpers
    h_modules = [build_named_routes_module]
    begin
      h_modules << eval("Site::#{@site.name.camelize}::BaseHelper")
    rescue NameError; end
    for h_module in h_modules
      response.template.helpers.send(:include, h_module)
    end
  end

  # Coumpute site layout
  def site_layout
    "site/#{@site.name}/layouts/application"
  end

  # Call block only if request last modified is older then argument. It also records
  # database lat_modified time.
  def on_modified last_modified, &block
    @last_modified = last_modified
    # TODO: make precise enough in sites and uncomment here
    #unless @test_last_modified_only
    #  if stale?( :last_modified => @last_modified )
    block.call  
    #  end
    #end
  end

  attr_reader :last_modified

  # Build module with named routes paths methods
  def build_named_routes_module
    theme_name = @site.name
    if Rails.configuration.cache_classes
      @@cached_named_routes_helpers ||= {}
      if @@cached_named_routes_helpers.key? theme_name
        return @@cached_named_routes_helpers[theme_name]
      end
    end
    
    mod = Module.new
    for cinfo in SiteIntrospector.introspect(@site).controllers_infos 
      controller_path_part = cinfo.name
      
      for pinfo in cinfo.pages_infos
        if cinfo.name == 'site'
          cmd = <<-EOS
          def #{pinfo.name}_site_path(site, *args)
            page_url(site, 'site', '#{pinfo.name}', *args)
          end
        EOS
        else
          cmd = <<-EOS
            def #{pinfo.name}_site_#{cinfo.name}_path(site, *args)
              page_url(site, '#{cinfo.name}', '#{pinfo.name}', *args)
            end
          EOS
        end
        mod.class_eval cmd
      end

    end

    if Rails.configuration.cache_classes
      @@cached_named_routes_helpers[theme_name] = mod
    end

    mod
  end

end