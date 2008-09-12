require 'rexml/document'

class Scrubator
  
  def scrubyt
    migrol = Scrubyt::Extractor.define do
      fetch 'http://migrol.ch/skin/td_idle_d.asp?navig=89'
  
      noOrder '/html/body/table/tr/td/table/tr[1]/td[4]/table[2]/tr/td[1]/table/tr/td/form/table/tr[1]/td[2]/table/tr[1]/td/font' 
  
      price '/html/body/table/tr/td/table/tr[1]/td[4]/table[2]/tr/td[1]/table/tr/td/form/table/tr[2]/td[2]/table[1]/tr[3]/td[3]/div/font'
            maxPrice '/html/body/table/tr/td/table/tr[1]/td[4]/table[2]/tr/td[1]/table/tr/td/form/table/tr[2]/td[2]/table[1]/tr[2]/td[3]/div'
            minPrice '/html/body/table/tr/td/table/tr[1]/td[4]/table[2]/tr/td[1]/table/tr/td/form/table/tr[2]/td[2]/table[1]/tr[4]/td[3]/div'
    end
  
    xml = REXML::Document.new(migrol.to_xml).root
  
    price = xml.elements["price"].text.to_f
  end
  
end