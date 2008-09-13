require File.dirname(__FILE__) + '/../test_helper'

class ScrubatorTest < Test::Unit::TestCase
  
  def test_scrubyt
    rip = Rip.new :name => 'test', :start_page => 'http://www.codez.ch'
    rip.bits.build :id => 1, :label => 'title', :xpath => '/html/body/h1', :generalize => false, :position => 1
    rip.bits.build :id => 2, :label => 'bird', :xpath => '/html/body/div', :generalize => false, :position => 2
    
    result = Scrubator.new.scrubyt(rip)
    puts result.to_hash.inspect
  end
  
end