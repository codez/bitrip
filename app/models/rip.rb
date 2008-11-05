class Rip < ActiveRecord::Base
  
  has_many :navi_actions, :order => 'position', :dependent => :destroy
  has_many :bits, :order => 'position', :dependent => :destroy
  
  acts_as_tree :order => 'position'
  
  before_validation :set_subrip_names
  
  validates_presence_of :name  
  validates_presence_of :bits, :unless => :multi?
  validates_presence_of :start_page, :unless => :multi?
  validates_exclusion_of :name, :in => ['rip', 'bit', 'navi_action', 'form_field', 'message']
  validates_format_of :start_page, :with => /^https?:\/\/.+/, :allow_nil => true, :message => 'should be a valid HTTP address'

 
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
  
  def sources
    pages = main_navi? ? [start_page] : children.collect { |c| c.start_page }
    pages.collect! do |page|
      protocol_slash = page.index('//')
      root_slash = page.index('/', protocol_slash + 2)
      root_slash = page.size if root_slash.nil?
      page[0..root_slash]
    end
    pages.uniq
  end
  
  def validate
    navi_actions.each { |navi| navi.validate }
    bits.each { |bit| bit.validate }
    children.each { |subrip| subrip.validate }
  end
  
  def save_revision(prev_id)
    self.current = true
    Rip.transaction do
      prev_rip = Rip.find prev_id
      self.revision = Rip.maximum(:revision) + 1
      validate_uniqueness_of_name unless prev_rip.name == name
      # TODO: should validate all first?
      if save
        if prev_rip.name != name
          Rip.update_all "name = #{quote(name, column_for_attribute(:name))}", ['name = ?', prev_rip.name]
        end
        Rip.update_all "current = FALSE", ['name = ? AND id <> ?', name, id]
        return true
      end 
    end
    false
  end
  
  def validate_uniqueness_of_name
    result = Rip.find :first, :conditions => ['name = ?', name]
    errors.add(:name, ActiveRecord::Errors.default_error_messages[:taken]) unless result.nil?
  end
  
  def multi?
    not children.empty?
  end
  
  def main_navi?
    !(start_page.nil? || start_page.empty?)
  end
  
  def complete_navi
    parent_id ? parent.navi_actions + navi_actions : navi_actions
  end
  
  def start_url
    parent_id && parent.start_page ? parent.start_page : start_page
  end
  
  def set_subrip_names
    self.current = true
    children.each do |subrip|
      subrip.name = name
    end
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
      bit_attrs = bits_param[index]
      if bit_attrs
        bit_attrs['position'] = pos
        rip.bits.build(bit_attrs)
        pos += 1
      end  
    end
  end
end
