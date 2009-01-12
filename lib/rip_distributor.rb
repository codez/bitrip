class RipDistributor
  
  LOCAL_DIR = File.dirname(__FILE__)
  XML_TMP_DIR = File.expand_path(LOCAL_DIR + "/../tmp/rips")
  
  def distribute_rips(scrubator, rips)
    threads = []
    ex = nil
    puts "ripping #{rips.size} rips"
    for r in rips
      threads << Thread.new(r) do |rip|
        begin
          puts "started thread #{rip.id}"
          snippets = proc_rip rip
          scrubator.assign_snippets(snippets, rip)
          
          puts "done thread #{rip.id}"
        rescue Exception => ex
          puts ex.message
          puts ex.backtrace.join("\n")
          ex = ex.message 
        end
      end
    end
    
    threads.each { |t|  t.join }
    ex
  end
  
  def proc_rip(rip)
    proc = IO.popen("ruby #{LOCAL_DIR}/rip_proc.rb", "w+")
    xml = hash_to_xml(record_to_hash(rip))
    proc.puts xml
    proc.close_write
    
    response = ''
    while line = proc.gets
      response += line
    end  
    
    raise response if response.size < 5 || response[0..4] != '<opt>'
    snippets = xml_to_hash(response)['snips']
    snippets.is_a?(Array) ? snippets : [snippets]
  end
  
  def hash_to_xml(hash)
    XmlSimple.xml_out(encode_types(hash), 'suppress_empty' => nil)
  end
  
  def xml_to_hash(xml)
    hash = XmlSimple.xml_in(xml, 
                           'force_array' => false, 
                           'force_content' => true,
                           'suppress_empty' => nil)
    decode_types hash                       
  end
  
  def write_xml(rip)
    xml = hash_to_xml(record_to_hash(rip))
    File.open(filename(rip.id), 'w') { |f| f.puts xml }
  end
  
  def read_xml(rip_id)
    config = xml_to_hash(filename(rip_id))
    GenericObject.new config
  end
  
private  

  def record_to_hash(record)
    hash = record.attributes.dup
    hash.default = '%- not in here -%'

    methods = record.class.const_defined?(:SCRUBATOR_METHODS) ? record.class.const_get(:SCRUBATOR_METHODS) : []
    methods.each do |m|
      hash[m.to_s] = serialize_method record, m
    end
    hash
  end
  
  def serialize_method(record, method)
    val = record.send(method)
    if serialize_array? val
      val = val.collect { |v| record_to_hash(v) }
    end
    val
  end
  
  def serialize_array?(value)
    value.kind_of?(Array) && 
      ! value.empty? && 
      value.first.class.const_defined?(:SCRUBATOR_METHODS)
  end
  
  def encode_types(hash)
    dup = {}
    hash.each do |key, value|
      dup[key.to_s] = 
        if value.is_a? Array
          value.collect {|h| encode_types h }
        elsif value.is_a? Hash
          encode_types value
        else
          hash_type value
        end
    end
    dup
  end
  
  def decode_types(hash)
    hash.each do |key, value|
      if hash_type?(value)
        hash[key] = parse_type value
      elsif value.is_a? Array
        value.collect! {|h| decode_types h }
      elsif value.is_a? Hash
        hash[key] = decode_types value
      end
    end
    hash
  end
  
  def parse_type(type_hash)
    content = type_hash['content']
    return case type_hash['type']
      when 'String' then content
      when 'Fixnum' then content.to_i
      when 'Date' then Date.parse(content)
      when 'FalseClass' then false
      when 'TrueClass' then true
      else puts type_hash; type_hash
    end  
  end
  
  def hash_type?(hash)
    hash.is_a?(Hash) && hash.has_key?('content') && hash.has_key?('type')
  end  
  
  def hash_type(value)
    value.nil? ? nil : {'content' => value.to_s, 'type' => value.class.to_s}
  end
  
  def filename(rip_id)
    "#{XML_TMP_DIR}/#{rip_id}.xml"
  end
  
end