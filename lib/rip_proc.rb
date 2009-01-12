#!/usr/bin/ruby
## stand-alone process for executing one bitRip

src_dir = File.dirname(__FILE__) + '/'
  
# redirect stdout to /dev/null
orig_stdout = $stdout
#$stdout = File.new('/dev/null', 'w')
$stdout = File.new("#{src_dir}/proc.log", 'w')

begin
  require 'rubygems'
  gem "RubyInline", "= 3.6.3"
  require 'scrubyt'
  require 'xmlsimple'
  require "#{src_dir}scrubator"
  require "#{src_dir}rip_distributor"
  require "#{src_dir}generic_object"

  xml = ''
  while line = gets
    xml += line
  end
  
  distributor = RipDistributor.new
  rip = distributor.xml_to_hash(xml)
  snippets = Scrubator.new.rip_one GenericObject.new(rip)
  orig_stdout.puts distributor.hash_to_xml('snips' => snippets)
  
rescue Exception => ex
  puts ex.message
  puts ex.backtrace.join("\n")
  orig_stdout.puts ex.message
end



