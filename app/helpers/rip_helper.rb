module RipHelper
  
  def bit_order
    (0..(@rip.bits.size - 1)).to_a.join(',')
  end
  
  def submit_to_target(label, action, target)
    submit_tag label, 
               :onclick => "submit_form('#{url_for(action)}', '#{target}'); return false;"
  end
  
  def frame_url(rip_name)
    rip_name && !rip_name.empty? ?
      url_for(:action => :show, :id => rip_name) : 
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
end
