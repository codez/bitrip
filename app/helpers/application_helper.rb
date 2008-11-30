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
  
  def render_js(options)
    replacements = options[:replace] || []
    locals = options[:locals] || {}
    replacements.each {|r| locals[r] = "0#{r.to_s}0" }
    html = render :partial => options[:partial], :locals => locals
    html = escape_javascript html
    replacements.each { |r| html = html.gsub("0#{r.to_s}0", "\" + #{r.to_s} + \"") }
    html
  end
  
  def sub_suffixes(index, subrip_index = nil)
    [id_suffix(index, subrip_index), field_suffix(index, subrip_index)]
  end
  
  def id_suffix(index, subrip_index = nil)
    subrip_index && subrip_index.to_i != -1 ? "sub_#{subrip_index}_#{index}" : index.to_s
  end
  
  def field_suffix(index, subrip_index = nil)
    subrip_index && subrip_index.to_i != -1  ? "_sub[#{subrip_index}][#{index}]" : "[#{index}]"
  end
  
  def sub_suffix(subrip_index = nil)
    subrip_index && subrip_index.to_i != -1 ? "_sub[#{subrip_index}]" : ""
  end
  
  def t(message_key)
    "<span class=\"quickinfo\"><a href=\"#\" class=\"help\">[?]<span>#{msg message_key}</span></a></span>"
  end
 
private  
  
  def type_partial(type)
    case type
      when :link then 'link'
      when :form then 'form_fields'
    end 
  end
  
end
