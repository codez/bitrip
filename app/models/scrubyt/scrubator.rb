

class Scrubator
  
  def initialize(rip)
    @rip = rip
  end
  
  # input rip, output html fragment
  def ripit()
   snippets = scrubyt(@rip).to_hash.collect { |p| p[:html] } 
   
   base_url = extract_base_url(Scrubyt::FetchAction.get_current_doc_url)
   fix_href_urls!(snippets, base_url)
   
   generate_html(snippets)
  end
  
  def scrubyt(rip)    # requires paramter instead of instvar because of class-eval
    Scrubyt::Extractor.define do
      fetch rip.start_page
          
      # extract all bits as html subtree        
      rip.bits.each do |bit|
        send("bit_#{bit.position}", bit.xpath, :generalize => bit.generalize ) do
          html :type => :html_subtree
        end
      end
    end
  end
  
  def generate_html(snippets)
    html = ''
    @rip.bits.each_with_index do |bit, i|
      html += "<p>\n"
      html += bit.label + ' ' unless bit.label.nil? || bit.label.empty?
      html += '<b>'
      html += snippets[i].nil? ? '&lt;error&gt;' : snippets[i]
      html += "</b>\n</p>\n"
    end
    html
  end
  
  def fix_href_urls!(snippets, base_url)
    snippets.each do |snip|
      snip.gsub!(/ (href|src)\=\"([^:]+)\"/i, " \\1=\"#{base_url}\\2\"")
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
  
end