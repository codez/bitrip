class RipDistributor
  
  XML_TMP_DIR = File.expand_path(File.dirname(__FILE__) + "/../tmp/rips")
  
  SERIALIZED_CLASSES = {Rip        => [:start_url, :complete_navi, :bits],
                        NaviAction => [:form_fields],
                        FormField  => [],
                        Bit        => [:xpath_scrubyt, :select_indizes_array] }
  
  def write_xml(rip)
    xml = XmlSimple.xml_out(to_hash(rip),
                            'suppress_empty' => nil)
    File.open(filename(rip.id), 'w') { |f| f.puts xml }
  end
  
  def read_xml(rip_id)
    config = XmlSimple.xml_in(filename(rip_id), 
                              'force_array' => false, 
                              'force_content' => true,
                              'suppress_empty' => nil)
    GenericObject.new extract_types(config)
  end
  
private  

  def to_hash(record)
    hash = record.attributes.dup
    inject_type_hash hash
    
    methods = SERIALIZED_CLASSES[record.class] || []
    methods.each do |m|
      hash[m.to_s] = serialize_method record, m
    end
    hash
  end
  
  def serialize_method(record, method)
    val = record.send(method)
    if val.kind_of?(Array) 
      if ! val.empty?  && SERIALIZED_CLASSES.has_key?(val.first.class)
        val = val.collect { |v| to_hash(v) }
      end
    else
      val = type_hash val
    end
    val
  end
  
  def inject_type_hash(hash)
    hash.each do |key, value|
      hash[key] = type_hash value
    end
  end
  
  def extract_types(hash)
    hash.each do |key, value|
      if type_hash?(value)
        hash[key] = parse_type(value)
      elsif value.is_a? Array
        value.collect! {|h| extract_types h }
      elsif value.is_a? Hash
        hash[key] = [extract_types value]
      end
    end
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
  
  def type_hash?(hash)
    hash.is_a?(Hash) && hash.has_key?('content') && hash.has_key?('type')
  end  
  
  def type_hash(value)
    value.nil? ? nil : {'content' => value.to_s, 'type' => value.class.to_s}
  end
  
  def filename(rip_id)
    "#{XML_TMP_DIR}/#{rip_id}.xml"
  end
  
end