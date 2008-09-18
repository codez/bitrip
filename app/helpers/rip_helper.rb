module RipHelper
  
  def bit_order
    (0..(@rip.bits.size - 1)).to_a.join(',')
  end
  
  def submit_to_target(label, action, target)
    submit_tag label, 
        :onclick => "submit_form('#{url_for(action)}', '#{target}'); return false;"
  end

end
