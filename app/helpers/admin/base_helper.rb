module ActionView::Helpers::AssetTagHelper
  alias_method :compute_public_path_without_admin, :compute_public_path
end

module Admin::BaseHelper

  #
  # Slots used by admin template. 
  #
  # You can overwrite these in your helpers, to customize layout used fot
  # particular controller
  #
  def extra_head_tags
    nil
  end

  def page_title
    'Photolio'
  end
  
  #
  # End slots
  #


  def remote_callback(options={})
    options[:with] ||= "'id=' + encodeURIComponent(element.id)"
    options[:loading] ||= "Element.update('#{options[:update]}', '<td style=\"width: 100px;\">#{loading_tag}</td>')"
    %(function(event){var element = Event.element(event); #{remote_function(options)}})
  end

  def protomenu_tag(selector, options={})
    javascript_tag(protomenu_js(selector, options))
  end

  # Build javascript tag, that loads tinymce to all textareas on page
  def load_tinymce_tag
    javascript_tag <<-EOS
      document.write(unescape("%3cscript src='#{compute_public_path('tiny_mce', 'tiny_mce', 'js')}' type='text/javascript'%3E%3C/script%3E"));
      Event.observe(window, 'load', function(){ tinyMCE.init({mode: 'textareas', theme: 'advanced',}); });
    EOS
  end

  def protomenu_js(selector, options={})
    options[:selector] = selector
    options[:menuItems] = '[' + options[:menuItems].map{|x| options_for_javascript(x)}.join(', ') + ']'
    %(new Proto.Menu(#{options_for_javascript(options)});)
  end

  def login_path
    new_admin_session_path
  end

  def logout_path
    delete_admin_session_path
  end

  protected

  def compute_public_path(source, dir, ext=nil)
    compute_public_path_without_photolio(source, "admin/#{dir}", ext)
  end

end
