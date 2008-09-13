gem "RubyInline", "= 3.6.3"
require 'scrubyt'

class Scrubator
  
  # input rip, output html fragment
  def ripit(rip, params = {})
   pattern = scrubyt rip, params  
   doc_url = Scrubyt::FetchAction.get_current_doc_url
   generate_html rip, pattern
  end
  
  def scrubyt(rip, params = {})
    Scrubyt::Extractor.define do
      fetch rip.start_page
          
      # extract all bits as html subtree        
      rip.bits.each do |bit|
        send("bit#{bit.id}", bit.xpath, :generalize => bit.generalize ) do
          html :type => :html_subtree
        end
      end
    end
  end
  
  def generate_html(rip, pattern)
    bit_list = pattern.to_hash
    html = ''
    rip.bits.each_index do |i|
      bit = rip.bits[i]
      html += "<p>\n"
      html += bit.label + ' ' unless bit.label.nil? || bit.label.empty?
      html += '<b>'
      html += bit_list[i][:html]
      html += "</b>\n</p>\n"
    end
    html
  end
  
end