module RipHelper
  
  def bit_order
    (0..(@rip.bits.size - 1)).to_a.join(',')
  end
  
  def submit_to_target(label, action, target)
    submit_tag label, 
               :onclick => "submit_form('#{url_for(action)}', '#{target}'); return false;"
  end

  def params_submitted?
    request.env["QUERY_STRING"] && 
    request.env["HTTP_REFERER"].include?(request.env["SERVER_NAME"]) 
  end
end
