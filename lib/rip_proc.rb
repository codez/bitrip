#!/usr/bin/ruby
## stand-alone process for executing one bitRip

src_dir = File.dirname(__FILE__) + '/'
  
# redirect stdout to /dev/null
orig_stdout = $stdout
orig_stderr = $stderr
#$stdout = File.new('/dev/null', 'w')
$stdout = File.new("#{src_dir}/proc.log", 'w')
$stderr = $stdout

begin
  require 'rubygems'
  gem "RubyInline", "= 3.6.3"
  require 'scrubyt'
  require 'xmlsimple'
  require "#{src_dir}scrubator"
  require "#{src_dir}rip_distributor"
  require "#{src_dir}generic_object"

  distributor = RipDistributor.new
  xml = readlines.join("")
  rip = distributor.xml_to_hash(xml)
  start = Time.now
  snippets = Scrubator.new.rip_one GenericObject.new(rip)
  t = Time.now - start
  orig_stdout.puts distributor.hash_to_xml('snips' => snippets, 'time' => t)
  
rescue Exception => ex
  puts ex.message
  puts ex.backtrace.join("\n")
  orig_stderr.puts ex.message
  exit 1
end


