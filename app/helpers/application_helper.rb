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
  
  def observe_type_field(type, index)
    observe_field "navi_#{index}_type_#{type}", 
        :url => { :controller => :navi_action, 
                  :action => :add_type_fields, 
                  :index => index },
        :with => "Form.serialize('ripform')",  
        :update => "navi_fields_#{index}",
        :after => "$('notify_#{index}').update('loading elements ...')",
        :loaded => "$('notify_#{index}').update('')"
  end
 
private  
  
  def type_partial(type)
    case type
      when :link then 'link'
      when :form then 'form_fields'
    end 
  end
  
end
