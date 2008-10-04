class Scrubator
  
  attr_reader :rip
  
  def initialize(rip)
    @rip = rip
  end
  
  # input rip, output html fragment
  def ripit
    snippets = scrubyt.to_hash
    base_url = extract_base_url(Scrubyt::FetchAction.get_current_doc_url)
    fix_href_urls!(snippets, base_url)
   
    generate_html(snippets)
  #rescue Exception => ex
  #  ex.message
  end
 
  def extract_links
    links = non_empty scrub_links
    links.collect! { |l| l[:links] }
    
    # add index to multiple labels
    add_index links
  end
  
  def extract_fields
    fields = non_empty scrub_fields
    
    form_fields = []
    fields.each do |f|
      type = f[:field_type].downcase.to_sym
      type = :text if type.nil?
      if FormField::TYPES.include? type
        field = FormField.new :name => f[:name]
        field.type = type
        # TODO: extract possible values for select
        form_fields.push field
      end  
    end
    form_fields
  end
  
  def scrubyt   # requires paramter instead of instvar because of class-eval
    scrubator = self
    
    Scrubyt::Extractor.define do
      scrubator.navigate_to_dest self
      
      scrubator.rip.bits.each do |bit|
        send("bit_#{bit.position}",  bit.xpath, :generalize => bit.generalize) do
          html :type => :html_subtree  
          bit bit.position.to_s, :type => :constant
        end
      end
    end
  end
  
  def scrub_links
    scrubator = self
    Scrubyt::Extractor.define do
      scrubator.navigate_to_dest self
      
      links '//a'
    end  
  end
  
  def scrub_fields
    scrubator = self
    Scrubyt::Extractor.define do
      scrubator.navigate_to_dest self
      
      inputs '//input' do
        name '//@name'
        field_type '//@type'
      end
      
      selects '//select' do
        name '//@name'
        field_type 'select', :type => :constant
      end
      
      textareas '//textarea' do
        name '//@name'
        field_type 'textarea', :type => :constant
      end
    end  
  end
  
  def navigate_to_dest(extractor)
    extractor.fetch rip.start_page
      
    rip.navi_actions.each do |navi|
      case navi.type
        when :form then
          navi.form_fields.each do |field|
          begin  
            case field.type
              when :text, :password, :hidden then 
                handle_field extractor, :fill_textfield, field
              when :textarea then
                handle_field extractor, :fill_textarea, field
              when :select then
                handle_field extractor, :select_option, field
              when :checkbox then
                extractor.check_checkbox field.name if field.value
              when :radio then
                handle_field extractor, :check_radiobutton, field
            end
          rescue RuntimeError => ex
            #TODO: raise meaningful exception
            raise 
          end
          end
          extractor.submit
        when :link then
          extractor.click_link navi.link_text
      end
    end 
  end
  
  def handle_field(extractor, method, field)
    unless field.value.nil? || field.value.empty?
      extractor.send method, field.name, field.value
    end  
  end
  
  def generate_html(snippets)
    puts snippets.inspect
    html = ''
    @rip.bits.each do |bit|
      html += "<p>\n"
      html += bit.label + ' ' unless bit.label.nil? || bit.label.empty?
      html += '<b>'
      
      snips = snippets.select { |s| s[:bit] == bit.position.to_s }
      snips.collect!{ |s| s[:html] }
      html += snips.empty? ? 'not found' : snips.join('<br/>')
      html += "</b>\n</p>\n"
    end
    html
  end
  
  def fix_href_urls!(snippets, base_url)
    snippets.each do |snip|
      snip[:html].gsub!(/ (href|src)\=\"([^:]+)\"/i, " \\1=\"#{base_url}\\2\"")
    end
  end

  def extract_base_url(doc_url)
    protocol_slash = doc_url.index('//')
    last_slash = doc_url.rindex('/')
    if last_slash.nil? || last_slash == protocol_slash + 1
      base_url = doc_url 
    else
      base_url = doc_url[0, last_slash]
    end
    base_url += '/' if base_url[-1] != $/
    base_url
  end

private

  def non_empty(extractor)
    extractor.to_hash.select { |p| not p.empty? }
  end
  
  def add_index(list)
    frequence = Hash.new(0)
    count = Hash.new(0)
    list.each { |l| frequence[l] += 1 }
    list.collect do |l| 
      if frequence[l] > 1 
        count[l] += 1
        "#{l}[#{count[l]}]" 
      else
        l
      end 
   end
  end
  
end
