module RipHelper
  
  def bit_order
    (0..(@rip.bits.size - 1)).to_a.join(',')
  end
  
  def submit_to_target(label, action, target)
    submit_tag label, 
               :onclick => "submit_form('#{url_for(action)}', '#{target}'); return false;"
  end
  
  def frame_url(rip)
    (rip.name && !rip.name.empty?) ?
      url_for(id_action(:show, rip)) : 
      url_for(:controller => :message, :action => :plain, :id => "frame_#{params[:action]}")
  end

  def params_submitted?
    request.env["QUERY_STRING"] && 
    (request.env["HTTP_REFERER"].include?(request.env["SERVER_NAME"]) ||          # local
     request.env["HTTP_REFERER"].include?(request.env["HTTP_X_FORWARDED_HOST"]) ) # production
  end
 
  def render_form(rip, action)
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
    confirm[:confirm] = "You might lose some of the currently entered\ninformation if you change the type of the rip." if options[:action] != 'add'
    link_to label, options, confirm
  end
 
end
