require 'rubygems'
gem "RubyInline", "= 3.6.3"
require 'scrubyt'
require "test/unit"

class ScrubytTest < Test::Unit::TestCase
  
  def test_scrubyt
    pattern = Scrubyt::Extractor.define do
      fetch 'http://www.bewegungsmelder.ch/bmonline.php?mtask=1&stask=19&task=result&date=today&subRegionID=1'
      
      alles '/html/body/div[3]/table/tr/td/table/tr[2]/td[2]/table/tr[2]/td' do
         nichts '/', :type => :html_subtree
      end
    end
    
    puts pattern.to_hash.inspect
  end
  
end