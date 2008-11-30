class Scrubator
  
  def initialize(rip)
    @rip = rip
  end
  
  # input rip, output html fragment
  def ripit
    rips = @rip.multi? ? @rip.children : [@rip]
    rips.each do |rip|
      snippets = scrubyt(rip).to_hash
      host_url, base_url = extract_base_url(Scrubyt::FetchAction.get_current_doc_url)
      fix_href_urls!(snippets, host_url, base_url)
     
      assign_snippets(snippets, rip)
    end  
    nil
  rescue Exception => ex
     ex.message
  end
 
  def extract_links
    links = non_empty scrub_links(@rip)
    links.collect! { |l| l[:links] }
    
    # add index to multiple labels
    add_index links
  end
  
  def extract_fields
    fields = non_empty scrub_fields(@rip)
    
    form_fields = []
    fields.each do |f|
      type = f[:field_type].downcase.to_sym
      type = :text if type.nil?
      if FormField::TYPES.include? type
        field = FormField.new :name => f[:name]
        field.type = type
        # extract possible values for radio
        if existing = form_fields.detect{ |e| field.same? e }
          if existing.type == :radio && type == :radio
            existing.add_option f[:value]
          end
        else
          field.add_option f[:value] if type == :radio
          form_fields.push field
        end
      end  
    end
    form_fields
  end
  
  def scrubyt(rip)   # requires paramter instead of instvar because of class-eval
    scrubator = self
    
    Scrubyt::Extractor.define do
      scrubator.navigate_to_dest self, rip
      
      rip.bits.each do |bit|
        pattern = send("bit_#{bit.position}", bit.xpath_scrubyt, :generalize => bit.generalize) do
          html :type => :html_subtree  
          bit bit.position.to_s, :type => :constant
        end
        
        pattern.select_indices(bit.select_indizes_array) unless bit.select_indizes.nil? || bit.select_indizes.strip.empty?
      end
      
      scrubator.next_pages self, rip
    end
  end
  
  def scrub_links(rip)
    scrubator = self
    Scrubyt::Extractor.define do
      scrubator.navigate_to_dest self, rip
      
      links '//a'
    end  
  end
  
  def scrub_fields(rip)
    scrubator = self
    Scrubyt::Extractor.define do
      scrubator.navigate_to_dest self, rip
      
      inputs '//input' do
        name '//@name'
        value '//@value'
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
  
  def navigate_to_dest(extractor, rip)
    extractor.fetch rip.start_url
    
    rip.complete_navi.each do |navi|
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
                handle_radio extractor, field
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
    unless field.value.nil? || (field.kind_of?(String) && field.value.empty?)
      #puts "send #{method} with #{field.name}=#{field.value}"
      extractor.send method, field.name, field.value
    end  
  end
  
  def handle_radio(extractor, field)
    field.value = field.options_arr.index(field.value) if field.value
    handle_field extractor, :check_radiobutton, field
  end
  
  def next_pages(extractor, rip)
    unless rip.next_link.nil? || rip.next_link.strip.empty?
      if rip.next_pages
        extractor.next_page rip.next_link, :limit => rip.next_pages
      else
        extractor.next_page rip.next_link
      end
    end
  end
  
  def assign_snippets(snippets, rip)
    rip.bits.each do |bit|
      snips = snippets.select { |s| s[:bit] == bit.position.to_s }
      bit.snippets = snips.collect{ |s| s[:html] }
      extract_img bit if bit.img?
    end
  end
  
  def fix_href_urls!(snippets, host_url, base_url)
    snippets.each do |snip|
      snip[:html].gsub!(/ (href|src|action)\=\"([^\/][^:\"]+)\"/i, " \\1=\"#{base_url}\\2\"")
      snip[:html].gsub!(/ (href|src|action)\=\"(\/[^:\"]+)\"/i, " \\1=\"#{host_url}\\2\"")
    end
  end

  def extract_base_url(doc_url)
    protocol_slash = doc_url.index('//')
    last_slash = doc_url.rindex('/')
    if last_slash.nil? || last_slash == protocol_slash + 1
      host_url = doc_url
      base_url = doc_url 
    else
      root_slash = doc_url.index('/', protocol_slash + 2)
      host_url = doc_url[0, root_slash]
      base_url = doc_url[0, last_slash]
    end
    host_url = host_url[0..-2] if host_url[-1] == $/
    base_url += '/' if base_url[-1] != $/
    [host_url, base_url]
  end
  
  def extract_img(bit)
    snip_imgs = []
    img_xpath = bit.xpath[(bit.xpath.rindex('/') + 4)..-1]
    index = nil
    if img_xpath.size > 0
      index = img_xpath[1..(img_xpath.rindex(']'))].to_i - 1
      index = 0 if index < 0
    end  
    bit.snippets.collect! do |snip|
      tag_depth = 0
      imgs = []
      img = nil
      snip.each_char do |c|
        case c
          when '<'  
            tag_depth += 1
            img = '<' if tag_depth == 1
          when '>'  
            tag_depth -= 1
            if img && img.size >= 4
              imgs << img + '>' 
              img = nil
            end
          when 'i', 'm', 'g', ' '  
            if img
              size = img.size
              if size >= 4 || '<img '.index(c) == size
                img += c
              else
                img = nil
              end
            end
          else
            if img && img.size > 4
              img +=c 
            else
              img = nil
            end 
          end
      end
      if index
         snip_imgs << imgs[index] if imgs[index]
      else 
         snip_imgs.concat imgs
      end
    end
    bit.snippets = snip_imgs
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
