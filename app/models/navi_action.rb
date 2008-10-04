class NaviAction < ActiveRecord::Base

  TYPES = [:form, :link]

  self.inheritance_column = nil
  
  belongs_to :rip
  has_many :form_fields, :dependent => :destroy
  
  validates_presence_of :type
  validates_inclusion_of :type, :in => TYPES
  validates_presence_of :link_text, :if => Proc.new {|navi_action| navi_action.type == :link }

  def type
    value = read_attribute 'type'
    value = value.to_sym if value
  end  
  
  def type=(value) 
    value = value.to_s 
    value = nil if value.empty?
    write_attribute 'type', value
  end
  
  def all_required_set?
    form_fields.all? { |field| !field.required || (field.value && !field.value.empty?) }
  end
  
end
