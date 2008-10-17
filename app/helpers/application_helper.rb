# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def render_type_partial(navi, index, subrip_index)
    if navi.type
      render :partial => "navi_action/#{type_partial(navi.type)}", 
             :locals => {:navi => navi, :index => index, :subrip_index => subrip_index}
    else     
      render :text => ''
    end
  end
  
  def observe_type_field(type, index, subrip_index)
    id_suffix, field_suffix = sub_suffixes index, subrip_index
    observe_field "navi_#{id_suffix}_type_#{type}", 
        :url => { :controller => :navi_action, 
                  :action => :add_type_fields, 
                  :index => index,
                  :subrip_index => subrip_index },
        :with => "Form.serialize('ripform')",  
        :update => "navi_fields_#{id_suffix}",
        :after => "$('type_#{id_suffix}').update('loading elements ...')",
        :loaded => "$('type_#{id_suffix}').update('<input type=\"hidden\" name=\"navi#{field_suffix}[type]\" value=\"#{type}\" />')"
  end
  
  def sub_suffixes(index, subrip_index = nil)
    id_suffix = subrip_index ? "sub_#{subrip_index}_#{index}" : index.to_s
    field_suffix = subrip_index  ? "_sub[#{subrip_index}][#{index}]" : "[#{index}]"
    [id_suffix, field_suffix]
  end
  
  def sub_suffix(subrip_index = nil)
    subrip_index ? "_sub[#{subrip_index}]" : ""
  end
  
  def t(message_key)
    "<span class=\"quickinfo\"><a class=\"help\">[?]<span>#{msg message_key}</span></a></span>"
  end
 
private  
  
  def type_partial(type)
    case type
      when :link then 'link'
      when :form then 'form_fields'
    end 
  end
  
end
