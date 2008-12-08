require File.dirname(__FILE__) + '/../test_helper'

class ScrubatorTest < Test::Unit::TestCase
  fixtures :all
    
  def setup
    @s = Scrubator.new(nil)
  end
  
  def test_scrubyt
    rip = Rip.find 1
    s = Scrubator.new(rip)
    result = s.ripit
    assert_equal nil, result
  end
  
  def test_extract_base_url
    assert_equal ['http://www.codez.ch','http://www.codez.ch/'], @s.extract_base_url('http://www.codez.ch/index.html')
    assert_equal ['http://www.codez.ch','http://www.codez.ch/blah/'], @s.extract_base_url('http://www.codez.ch/blah/other.html')
    assert_equal ['http://www.codez.ch','http://www.codez.ch/'], @s.extract_base_url('http://www.codez.ch')
    assert_equal ['http://www.codez.ch','http://www.codez.ch/blah/'], @s.extract_base_url('http://www.codez.ch/blah/')
  end
  
  def test_fix_href_urls
    base_url = 'http://www.codez.ch/blah/'
    host_url = 'http://www.codez.ch'
    assert_equal [:html => "<a href=\"#{base_url}index.html\" class=\"test\"/>"], @s.fix_href_urls!([:html => '<a href="index.html" class="test"/>'], host_url, base_url)
    assert_equal [:html => "<a href=\"http://www.example.com/index.html\" class=\"test\"/>"], @s.fix_href_urls!([:html => '<a href="http://www.example.com/index.html" class="test"/>'], host_url, base_url)
    assert_equal [:html => "<img src=\"#{host_url}/example.jpg\"/>"], @s.fix_href_urls!([:html => '<img src="/example.jpg"/>'], host_url, base_url)
    assert_equal [:html => "<a href=\"mailto:spam@codez.ch\"/>"], @s.fix_href_urls!([:html => '<a href="mailto:spam@codez.ch"/>'], host_url, base_url)
  end
  
  
  ## scrubyt does not really support this..
  def ignore_test_concurrency
    threads = []

    5.times do |i|
      threads << Thread.new(Rip.find(2), i) do |rip, i|
        rip.children.each {|c| puts c.object_id }
        puts i.to_s + " - " + rip.object_id.to_s
        s = Scrubator.new(rip)
        puts i.to_s + " - goes rippin'"
        result = s.ripit
        puts i.to_s + " - assertin'"
        assert_equal nil, result
        assert_snippets rip
        puts i.to_s + " - done'"
      end
      puts "defined " + i.to_s
    end
  
    threads.each { |aThread|  aThread.join }
  end

  def test_multi
    rip = Rip.find 2
    s = Scrubator.new(rip)
    result = s.ripit
    assert_equal nil, result
    assert_snippets rip
  end
  
  def assert_snippets(rip)
    snippets = [ ["69.25 CHF / 100 Liter", "73.50 CHF / 100 Liter"],
               ["<img src=\"http://www.febizz.com/AGROLA/PICS/t.gif\" height=\"1\" width=\"10\" />", "<img src=\"http://www.febizz.com/AGROLA/PICS/t.gif\" height=\"3\" width=\"250\" /><br />2. Liefertermin, Zahlungsart<br /><img src=\"http://www.febizz.com/AGROLA/PICS/t.gif\" height=\"3\" width=\"1\" />"],
               ["67.90"],
               ["<img src=\"http://migrol.ch/images/g_heizoel_cumulus03.gif\" border=\"0\" vspace=\"15\" hspace=\"0\" />", "Als Privatkunde mit einer Bestellmenge bis 10 000 Liter erhalten Sie 100 CUMULUS-Bonuspunkte pro 1000 Liter. <br />Bei Bestellung bitte Ihre CUMULUS-Karte bereithalten."],
               ["<img src=\"http://codez.ch/art/dropahead.gif\" align=\"center\" height=\"620\" alt=\"drop ahead\" width=\"707\" />"],
               ["<a href=\"http://codez.ch/index.html\">:Home</a>"]]
    count = 0
    rip.children.each do |c|
      c.bits.each do |bit|
        assert_equal snippets[count], bit.snippets
        count += 1
      end
    end
  end
  
  def print_snippets(rip)
    rip.bits.each do |bit|
      puts bit.snippets.inspect
    end
    rip.children.each { |c| print_snippets c }
  end
    
end