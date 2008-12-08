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
    rip = Rip.find 1
    distributor = RipDistributor.new
    distributor.write_xml rip
    o = distributor.read_xml rip.id
    puts PP.pp(o.attrs, "", 60)
  end
  
end