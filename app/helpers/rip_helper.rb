module RipHelper
  
  def bit_order
    (0..(@rip.bits.size - 1)).to_a.join(',')
  end
  
  def submit_to_target(label, action, target)
    submit_tag label, 
               :onclick => "submit_form('#{url_for(action)}', '#{target}'); return false;"
  end
  
  def frame_url(rip)
    (rip && rip.name && !rip.name.empty?) ?
      url_for(id_action(:show, rip)) : 
      url_for(:controller => :message, :action => :plain, :id => "frame_#{params[:action]}")
  end

  def params_submitted?
    request.env["QUERY_STRING"].size > 0 && 
     request.env["HTTP_REFERER"].include?(request.env["SERVER_NAME"]) 
  end
 
  def current_link
    if request.env['REQUEST_URI'].include?(request.env['SERVER_NAME'])
      request.env['REQUEST_URI']
    else
      "http://#{request.env['SERVER_NAME']}#{request.env['REQUEST_URI']}"
    end
  end
 
  def render_form(action)
    render :partial => 'form', :locals => { :action => action }
  end
 
  def id_action(action, rip)
     @use_id ? 
        { :action => "#{action.to_s}_id".to_sym, :id => rip.id } : 
        { :action => action, :id => rip.name }
  end
  
  def change_type_link(label, type)
    options = {:action => controller.action_name, :type => type}
    confirm = {}
    confirm[:confirm] = "You will lose some of the currently entered\ninformation if you change the type of this bitRip." if options[:action] != 'add'
    link_to label, options, confirm
  end
 
  def edit_js
    if ENV['RAILS_ENV'] == 'production'
      javascript_include_tag 'edit'
    else
      javascript_include_tag '/rip/edit_js'
    end  
  end
end
