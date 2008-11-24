class Rip < ActiveRecord::Base
  
  has_many :navi_actions, :order => 'position', :dependent => :destroy
  has_many :bits, :order => 'position', :dependent => :destroy
  
  acts_as_tree :order => 'position'
  
  before_save :set_subrip_names
  
  validates_presence_of :name, :unless => :parent
  validates_format_of :name, :with => /^[A-Za-z0-9\-_\.]*$/, :unless => :parent, :message => "may only contain letters, numbers or one of '._-'"
  validates_exclusion_of :name, :in => ['rip', 'bit', 'navi_action', 'form_field', 'message']
  validates_presence_of :bits, :unless => :multi?
  validates_presence_of :start_page, :unless => :multi?
  validates_format_of :start_page, :with => /^https?:\/\/.+/, :allow_nil => true, :message => 'must be a valid HTTP address'

  SANDBOX_NAME = 'sandbox'
  
  attr_writer :ignore_name_validation


  def has_fields?
    navi_actions.any? { |navi| navi.type == :form }
  end
  
  def all_required_set?
    navi_actions.all? { |navi| navi.all_required_set? }
  end
  
  def multi?
    not children.empty?
  end
  
  def main_navi?
    !(start_page.nil? || start_page.empty?)
  end
   
  def bit_order
    (0..(bits.size - 1)).to_a.join(',')
  end
    
  def page_info
    start_page.size > 30 ? start_page[0..30] + '...' : start_page
  end
  
  def start_url
    parent && parent.start_page ? parent.start_page : start_page
  end
  
  def complete_navi
    parent_id ? parent.navi_actions + navi_actions : navi_actions
  end
  
  def sources
    pages = main_navi? ? [start_page] : children.collect { |c| c.start_page }
    pages.collect! do |page|
      protocol_slash = page.index('//')
      root_slash = page.index('/', protocol_slash + 2)
      root_slash = root_slash.nil? ? page.size : root_slash - 1
      page[0..root_slash]
    end
    pages.uniq
  end
  
  def save_revision(prev_id)
    self.current = true
    Rip.transaction do
      prev_rip = Rip.find prev_id
      self.ignore_name_validation = (prev_rip.name == name)
      self.revision = Rip.maximum(:revision, :conditions => ['name = ?', prev_rip.name]) + 1
      # TODO: should validate all first?
      if save
        if prev_rip.name != name
          Rip.update_all({:name => name}, ['name = ?', prev_rip.name])
        end
        Rip.update_all "current = FALSE", ['name = ? AND id <> ?', name, id]
        return true
      end 
    end
    false
  end
 
  def validate
    navi_actions.each { |navi| navi.validate }
    bits.each { |bit| bit.validate }
    children.each { |subrip| subrip.validate }
  end
  
  def validate_on_create
    unless @ignore_name_validation
      result = Rip.find :first, :conditions => ['name = ?', name]
      errors.add(:name, ActiveRecord::Errors.default_error_messages[:taken]) unless result.nil?
    end
  end
  
  def set_subrip_names
    children.each do |subrip|
      subrip.name = name
    end
  end
  
  def self.build_type(type = :single)
    type = type.to_sym
    type = :single unless [:single, :multi, :common].include?(type)
    rip = Rip.new
    child = rip.children.build :position => 1 if type != :single
    (type == :multi ? child : rip).start_page = 'http://'
    (child ? child : rip).bits.build :xpath => '/'
    rip
  end

  def to_type(type = :single)
    clone = Rip.new
    clone.id = id
    clone.name = name
    clone.description = description
    case type.to_sym
      when :single then
        return self unless multi?
        child = children.first
        clone.start_page = child.start_page unless main_navi?
        clone.next_link = child.next_link
        clone.next_pages = child.next_pages
        navi_actions.each do |navi|
          clone.navi_actions << navi
        end
        child.navi_actions.each do |navi|
          navi.position = navi_actions.empty? ? 1 : navi_actions.last.position + 1
          clone.navi_actions << navi 
        end
        child.bits.each do |bit| 
          clone.bits << bit 
        end  
      when :multi then
        return self unless main_navi?
        if multi?
          pos = navi_actions.last.position
          children.each do |child|
            clone << child
            child.navi_actions.each { |navi| navi.position += pos }
            copy_attrs child
          end          
        else  
          child = clone.children.build :position => 1 
          copy_attrs child
          bits.each do |bit|
            child.bits << bit
          end
        end
      when :common then
        return self if multi? && main_navi?
        if multi?
          clone.start_page = children.empty? ? 'http://' : children.first.start_page
          children.each do |child|
            clone.children << child
            child.start_page = nil
          end 
        else  
          clone.start_page = start_page
          child = clone.children.build :position => 1
          child.next_link = next_link
          child.next_pages = next_pages
          bits.each do |bit|
            child.bits << bit
          end
          navi_actions.each do |navi|
            clone.navi_actions << navi
          end
        end
    end
    clone
  end
  
  def build_from(params)
    self.attributes = params['rip'].reject{|key, val| key == 'name' }
    self.name = params['rip']['name'] unless self.name == SANDBOX_NAME
    
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
      sub_rip.parent = self
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
  
private

  def copy_attrs(child)
    child.start_page = start_page
    child.next_link = next_link
    child.next_pages = next_pages
    navi_actions.each do |navi|
      child.navi_actions << navi
    end
  end
  
end
