require 'ftools'


class ActionController::Base
  public :render_component_as_string
end

module Publisher

  class AbstractPublisher

    def clenup_site_part_from_path(path)
      site_prefix = "/#{@site.name}"
      site_prefix_range = 0..(site_prefix.size-1)
      if path[site_prefix_range] == site_prefix
        path[site_prefix_range] = ''
      end
      path
    end

    # Publish single page
    def publish(page_info, mtime)
      mtime = normalize_time(mtime)
      page_path = @context.url_for( page_info.merge( :only_path => true, :skip_relative_url_root => true ) )
      page_path = clenup_site_part_from_path(page_path)
      if older?(page_path, mtime)
        if File.exists?(File.join(@base_path, page_path))
          fmtime = File.new(File.join(@base_path, page_path)).mtime
          equals = (fmtime == mtime)
          @context.logger.info "-- file #{page_path} changed: #{fmtime} < #{mtime} [#{equals}]"
        end
        page_params = page_info.merge(:published => true)
        page_controller = page_params.delete(:controller)
        page_action = page_params.delete(:action)
        body = @context.render_component_as_string( :controller => page_controller,
                                                    :action => page_action,
                                                    :params => page_params )
        save!(page_path, body, mtime)
        page_path
      end
    end

    # Publish assets folder
    def copy_assets_folder()
      src_base_path = File.join(RAILS_ROOT, 'public', @site.name)
      
      def copy_folder(src_base_path, folder)
        folder_path = File.join(src_base_path, folder)
        Dir.new(folder_path).each do |file_name|
          if file_name != '.' and file_name != '..'
            file_path = File.join(folder_path, file_name)
            file_relative_path = File.join(folder, file_name)
            if File.directory? file_path
              copy_folder(src_base_path, file_relative_path)
            elsif File.file? file_path
              mtime = File.new(file_path).mtime
              if older?(file_relative_path, mtime)
                content = ''
                File.open(file_path, "rb"){ |f| content = f.read() }
                save!(file_relative_path, content, mtime)
              end
            end
          end
        end
      end

      copy_folder(src_base_path, '')
    end

    protected

    def initialize(context, site)
      @context = context
      @site = site
    end

    # Normalize time from various formats to unix type
    def normalize_time(time)
      if time.is_a? DateTime
        return time.to_time
      elsif time.is_a? ActiveSupport::TimeWithZone
        return time.time
      else 
        return time
      end
    end

    #
    # Final classes must implement these
    #

    # Test if file last modification time is older than ctime
    def older?(path, mtime)
      raise RuntimeError('Unimplemented')
    end

    # Save content in path with last change time equivalent to last page modification time
    def save!(path, content, mtime)
      raise RuntimeError('Unimplemented')
    end

  end


  class LocalFilePublisher < AbstractPublisher
    def initialize(context, site)
      super(context, site)
      @base_path = @site.site_params.publish_location
      validate_folder(@base_path)
    end

    def validate_folder(path)
      if not (path and (path != '') and File.directory?(path))
        raise ArgumentError.new("Invalid publisher destination path: #{path}. Folder  must already exists.")
      elsif not File.writable?(path)
        raise ArgumentError.new("Publisher destination path '#{path}' must be writable.")
      end
    end

    def older?(path, time)
      file_path = File.join(@base_path, path)
      return (not (File.exists?(file_path) and (File.new(file_path).mtime >= time)))
    end

    def save!(path, content, mtime)
      file_path = File.join(@base_path, path)
      FileUtils.mkdir_p( File.dirname( file_path ) )
      File.open(file_path, "wb"){ |f| f.write(content) }
      File.utime(Time.new, mtime, file_path)
    end
  end


  def self.publisher_for_location(context, site)
    return LocalFilePublisher.new(context, site)
  end

end
