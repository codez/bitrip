class NaviActionController < ApplicationController
  
  hide_action :render_type_partial
  helper_method :render_type_partial
  
  
  def add
    @navi_action = NaviAction.new :position => params[:index].to_i + 1
  end
  
  def remove
  end

  def add_type_fields
    index = params['index'].to_i
    navi = NaviAction.new(:position => index + 1)
    navi.type = params[:type].to_sym   # type is special, can't add to '.new' hash
    render_type_partial navi, index
  end
  
  
  ## helper methods
  
  def render_type_partial(navi, index)
    if navi.type
      render :partial => type_partial(navi.type), 
             :locals => {:navi => navi, :index => index}
    else     
      render :text => ''
    end
  end

private

  def type_partial(type)
    case type.to_sym
      when :link then 'link'
      when :form then 'form_fields'
    end 
  end
  
end
