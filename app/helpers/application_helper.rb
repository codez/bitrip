# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def render_type_partial(navi, index)
    puts navi.type
    if navi.type
      render :partial => "navi_action/#{type_partial(navi.type)}", 
             :locals => {:navi => navi, :index => index}
    else     
      render :text => ''
    end
  end
 
private  
  
  def type_partial(type)
    case type
      when :link then 'link'
      when :form then 'form_fields'
    end 
  end
  
end
