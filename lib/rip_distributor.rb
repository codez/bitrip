class RipDistributor
  
  XML_TMP_DIR = File.expand_path(File.dirname(__FILE__) + "/../tmp/rips")
  
  def write_xml(rip)
    xml = rip.to_xml :include => {:navi_actions => {:include => :form_fields}, 
                                  :bits => {:methods => [:xpath_scrubyt, :select_indizes_array]}},
                     :methods => [:start_url, :complete_navi]
    File.open(filename(rip.id), 'w') { |f| f.puts xml }
  end
  
  def read_xml(rip_id)
    config = XmlSimple.xml_in(filename(rip_id), 
                              'force_array' => false, 
                              'force_content' => true)
    GenericObject.new config
  end
  
private  
  
  def filename(rip_id)
    "#{XML_TMP_DIR}/#{rip_id}.xml"
  end
  
end