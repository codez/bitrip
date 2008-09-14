require File.dirname(__FILE__) + '/../test_helper'

class ScrubatorTest < Test::Unit::TestCase
  fixtures :all
    
  def setup
    @s = Scrubator.new    
  end
  
  def test_scrubyt
    rip = Rip.find 1
    result = @s.ripit rip
    puts result.inspect
  end
  
  def test_extract_base_url
    assert_equal 'http://www.codez.ch/', @s.extract_base_url('http://www.codez.ch/index.html')
    assert_equal 'http://www.codez.ch/blah/', @s.extract_base_url('http://www.codez.ch/blah/other.html')
    assert_equal 'http://www.codez.ch/', @s.extract_base_url('http://www.codez.ch')
    assert_equal 'http://www.codez.ch/blah/', @s.extract_base_url('http://www.codez.ch/blah/')
  end
  
  def test_fix_href_urls
    base_url = 'http://www.codez.ch/'
    assert_equal ["<a href=\"#{base_url}index.html\" class=\"test\"/>"], @s.fix_href_urls!(['<a href="index.html" class="test"/>'], base_url)
    assert_equal ["<a href=\"http://www.example.com/index.html\" class=\"test\"/>"], @s.fix_href_urls!(['<a href="http://www.example.com/index.html" class="test"/>'], base_url)
    assert_equal ["<img src=\"#{base_url}/example.jpg\"/>"], @s.fix_href_urls!(['<img src="/example.jpg"/>'], base_url)
    assert_equal ["<a href=\"mailto:spam@codez.ch\"/>"], @s.fix_href_urls!(['<a href="mailto:spam@codez.ch"/>'], base_url)
    
  end
end