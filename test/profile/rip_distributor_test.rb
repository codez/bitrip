require File.dirname(__FILE__) + '/../profile_test_helper'
require 'pp'

class RipDistributorTest < Test::Unit::TestCase  
  include RubyProf::Test
  
  fixtures :all
  
  def test_distribute_profile
    rip = Rip.find 6
    
    stats = []
    1.times do
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
