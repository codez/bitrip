class NaviActionController < ApplicationController
  protect_from_forgery :except => :add_type_fields

  def add_type_fields
    rip = Rip.new
    rip.build_from params
    #TODO check index == rip.navi_actions.size - 1
    subrip_index = nil 
    subrip_index = params['subrip'].keys.sort.index(params['subrip_index']) if params['subrip_index'] && params['subrip_index'].to_i != -1
    puts subrip_index
    subrip = subrip_index ? rip.children[subrip_index] : rip
    populate_type_fields subrip
  end

private
  
  def populate_type_fields(rip)
    return if start_page_missing?(rip)
    
    navi = rip.complete_navi.last
    # check if navi type is defined. should not happen here
    if navi.type.nil? || navi.type.empty?
       render :text => ''
       return
    end
    
    rip.navi_actions.delete navi
    index = params[:index]
    begin
      case navi.type
        when 'link' then 
          @links = Scrubator.new.extract_links rip
          render_populate_result navi, index, @links, 'link', 'links'
        when 'form' then 
          navi.form_fields = Scrubator.new.extract_fields rip
          render_populate_result navi, index, navi.form_fields, 'form_fields', 'form fields'
      end
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace.join("\n")
      render_problem "Could not load navigation elements: #{ex.message}"
    end
  end
  
  def start_page_missing?(rip)
    if rip.start_url.nil? || rip.start_url.empty?
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
