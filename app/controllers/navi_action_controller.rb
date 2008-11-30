class NaviActionController < ApplicationController
  protect_from_forgery :except => :add_type_fields

  def add_type_fields
    rip = Rip.new
    rip.build_from params
    #TODO check index == rip.navi_actions.size - 1
    params['subrip_index'] = nil if params['subrip_index'].to_i == -1
    subrip = params['subrip_index'] ? rip.children[params['subrip_index'].to_i] : rip
    populate_type_fields subrip
  end

private
  
  def populate_type_fields(rip)
    return if start_page_missing?(rip)
    
    navi = rip.complete_navi.last
    if navi.type.nil? || navi.type.to_s.empty?
       render :text => ''
       return
    end
    
    rip.navi_actions.delete navi
    index = params[:index]
    extractor = Scrubator.new rip
    case navi.type
      when :link then 
        @links = extractor.extract_links
        render_populate_result navi, index, @links, 'link', 'links'
      when :form then 
        navi.form_fields = extractor.extract_fields
        render_populate_result navi, index, navi.form_fields, 'form_fields', 'form fields'
    end
  end
  
  def start_page_missing?(rip)
    if rip.start_page.empty?
      render_problem 'Please specify a start page before adding navigation'
      return true
    end
    false
  end
  
  def render_populate_result(navi, index, list, partial, label)
    if list.empty?
      render_no_possibilities_found label
    else
      render_type_partial partial, navi, index
    end
  end
  
  def render_type_partial(type_partial, navi, index)
    render :partial => type_partial, 
           :locals => {:navi => navi, 
                       :index => index, 
                       :subrip_index => params['subrip_index']}
  end
         
  def render_no_possibilities_found(desc)
    render_problem "No #{desc} have been found on this page"  
  end
  
  def render_problem(message)
    render :partial => 'problem', :locals => { :problem => message }
  end
  
end
