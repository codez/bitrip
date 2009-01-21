class RipDistributor
  
  LOCAL_DIR = File.dirname(__FILE__)
  XML_TMP_DIR = File.expand_path(LOCAL_DIR + "/../tmp/rips")
  
  def distribute_rips(scrubator, rips)
    threads = []
    ex = nil
    
    @preTime = 0
    @procTime = 0
    @postTime = 0
    @ripTime = 0
    
    for r in rips
      start = Time.now
      # use active record a last time before diving into threads...
      rip_hash = record_to_hash(r)  
      @preTime += Time.now - start
      threads << Thread.new(r, rip_hash) do |rip, hash|
        begin
          snippets = proc_rip hash
          scrubator.assign_snippets(snippets, rip)
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
  
  def stats
    [@preTime, @procTime, @ripTime, @postTime]
  end
  
  def proc_rip(rip)
    start = Time.now
    session = Session.new
    xml = hash_to_xml(rip)
    @preTime += Time.now - start
    start = Time.now
    response, err = session.execute "ruby #{LOCAL_DIR}/rip_proc.rb",
                             :stdin => xml  
    @procTime += Time.now - start                         
    start = Time.now
    #raise response if response.size < 5 || response[0..4] != '<opt>'
    raise err if session.exit_status > 0
    response = xml_to_hash response
    @postTime += Time.now - start
    @ripTime += response['time']
    snippets = response['snips']
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
          value.collect {|h| h.is_a?(Hash) ? encode_types(h) : hash_type(h) }
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
    content = type_hash['valXXcontent']
    return case type_hash['valXXtype']
      when 'String' then content
      when 'Fixnum' then content.to_i
      when 'Float' then content.to_f
      when 'Date' then Date.parse(content)
      when 'FalseClass' then false
      when 'TrueClass' then true
      else raise type_hash.inspect
    end  
  end
  
  def hash_type?(hash)
    hash.is_a?(Hash) && hash.has_key?('valXXtype')
  end  
  
  def hash_type(value)
    value.nil? ? nil : {'valXXcontent' => value.to_s, 'valXXtype' => value.class.to_s}
  end
  
  def filename(rip_id)
    "#{XML_TMP_DIR}/#{rip_id}.xml"
  end
  
end