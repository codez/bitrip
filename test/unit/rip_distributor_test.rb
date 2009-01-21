require File.dirname(__FILE__) + '/../test_helper'
require 'pp'

class RipDistributorTest < Test::Unit::TestCase
  fixtures :all
  
  def test_generic_object
    o = GenericObject.new({ 'blah' => 1, 'text' => 'tests', 'kids' => [{'a' => 1}, {'a' => 2}] })
    assert_equal(1, o.blah)
    assert_equal('tests', o.text)
    assert_equal(2, o.kids.size)
    assert_equal(1, o.kids[0].a)
    assert_equal(2, o.kids[1].a)
  end
  
  def test_serialize_rip
    rip = Rip.find 3
    distributor = RipDistributor.new
    distributor.write_xml rip
    o = distributor.read_xml rip.id
    
    assert_equal(rip.start_page, o.start_page)
    assert_equal(rip.name, o.name)
    i = 0
    rip.bits.each do |bit|
      obit = o.bits[i]
      assert_equal(bit.label, obit.label)
      indizes = obit.select_indizes_array
      indizes = [indizes] unless indizes.nil? || indizes.is_a?(Array)
      assert_equal(bit.select_indizes_array, indizes)
      assert_equal(bit.xpath, obit.xpath)
      assert_equal(bit.xpath_scrubyt, obit.xpath_scrubyt)
      assert_equal(bit.position, obit.position)
      i += 1
    end
    i = 0
    rip.complete_navi.each do |navi|
      onavi = o.complete_navi[i]
      assert_equal(navi.position, onavi.position)
      assert_equal(navi.type, onavi.type)
      assert_equal(navi.link_text, onavi.link_text)
      j = 0
      navi.form_fields.each do |field|
        ofield = onavi.form_fields[j]
        assert_equal(field.type, ofield.type)
        assert_equal(field.name, ofield.name)
        assert_equal(field.value, ofield.value)
        assert_equal(field.constant, ofield.constant)
        j += 1
      end
      i += 1
    end
  end
  
  def test_distribute
    rip = Rip.find 2
    res = Scrubator.new.ripit(rip, false)
    puts res if res
    rip.children.each do |subrip|
      puts subrip.id
      subrip.bits.each do |bit|
        puts bit.snippets.inspect
      end
    end
  end
  
  def test_distribute_profile
    rip = Rip.find 6
    stats = []
    10.times do
      start = Time.now
      rips = rip.multi? ? rip.children : [rip]
      distributor = RipDistributor.new
      ex = distributor.distribute_rips(Scrubator.new, rips)
      puts ex if ex
      stats.push([Time.now - start] + distributor.stats)
    end
    puts "Distributed:"
    puts avg(stats).inspect
    
    stats = []
    10.times do
      start = Time.now
      ex = Scrubator.new.ripit(rip, false)
      puts ex if ex
      stats.push [Time.now - start]
    end
    puts "Serial:"
    puts avg(stats).inspect
  end
  
  def avg(arr)
    avg = []
    arr.first.size.times { avg.push 0 }
    arr.each_with_index do |a, i|
      a.each_with_index do |v, i|
        avg[i] += v
      end
    end
    avg.collect { |av| av / arr.size }
  end
  
end
