require 'rubygems'
gem "RubyInline", "= 3.6.3"
require 'scrubyt'
require "test/unit"

class ScrubytTest < Test::Unit::TestCase
  
  def test_scrubyt
    pattern = Scrubyt::Extractor.define do
      fetch 'http://www.google.com/ncr'
      
      fill_textfield 'q', 'pascal'
      submit
      
      alles '/body/div[3]/div/ol/li/h3' do
         nichts '/', :type => :html_subtree
      end
      next_page "Next", {:limit => 2}
    end
    
    puts pattern.to_hash.size
  end
  
end