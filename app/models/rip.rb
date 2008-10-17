class Rip < ActiveRecord::Base
  
  has_many :navi_actions, :order => 'position', :dependent => :destroy
  has_many :bits, :order => 'position', :dependent => :destroy
  
  acts_as_tree :order => 'position'
  
  validates_presence_of :name
  validates_uniqueness_of :name, :unless => :parent_id
  validates_exclusion_of :name, :in => ['rip', 'bit', 'navi_action', 'form_field']
  validates_format_of :start_page, :with => /^https?:\/\/.+/, :message => 'should be a valid HTTP address'
  validates_presence_of :bits, :unless => :multi?
 
  def bit_order
    (0..(bits.size - 1)).to_a
  end
  
  def all_required_set?
    navi_actions.all? { |navi| navi.all_required_set? }
  end
  
  def has_fields?
    navi_actions.any? { |navi| navi.type == :form }
  end
  
  def page_info
    start_page.size > 30 ? start_page[0..30] + '...' : start_page
  end
  
  def validate
    navi_actions.each { |navi| navi.validate }
    bits.each { |bit| bit.validate }
  end
  
  def multi?
    not children.empty?
  end
  
  def main_navi?
    !(start_page.nil? || start_page.empty?)
  end
  
  def build_from(params)
    self.attributes = params['rip']
    
    # build navi actions
    self.navi_actions.clear
    build_navi self, params['navi'], params['fields']
    
    # build bits
    self.bits.clear
    build_bits self, params['bits'], params['bit_order']
    
    # build sub rips
    self.children.clear
    pos = 1
    params['subrip'].values.each_with_index do |subrip, index|
      sub_rip = self.children.build subrip
      sub_rip.name = self.name
      sub_rip.position = pos
      build_navi sub_rip, params['navi_sub'][index.to_s], params['fields_sub'][index.to_s]
      build_bits sub_rip, params['bits_sub'][index.to_s], params['bit_order_sub'][index.to_s]
      pos += 1
    end
  end
  
  def build_navi(rip, navis_param, fields_param)
     navis_param.values.each_with_index do |navi, index|
      navi_action = rip.navi_actions.build navi
      navi_action.type = navi['type'] unless navi['type'].empty?
      
      # build form fields
      fields = fields_param[index.to_s]
      if fields
        fields.each_value do |field|
          form_field = navi_action.form_fields.build field
          form_field.type = field['type']
        end
      end
    end
  end
  
  def build_bits(rip, bits_param, bit_order)
    pos = 1
    bit_order.split(',').each do |index|
      bit_attrs =bits_param[index]
      if bit_attrs
        bit_attrs['position'] = pos
        rip.bits.build(bit_attrs)
        pos += 1
      end  
    end
  end
end
