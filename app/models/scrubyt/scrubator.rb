gem "RubyInline", "= 3.6.3"
require 'scrubyt'

class Scrubator
  
  def scrubyt(rip, params = {})
    document = Scrubyt::Extractor.define do
      fetch rip.start_page
        
      rip.bits.each do |bit|
        send("bit#{bit.id}", bit.xpath, :generalize => bit.generalize ) do
          html :type => :html_subtree
        end
      end
    end
  
    doc_url = Scrubyt::FetchAction.get_current_doc_url
      
    document
  end
  
end