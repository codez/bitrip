class NaviAction < ActiveRecord::Base

  TYPES = [:form, :link]

  self.inheritance_column = nil
  
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
  
  def requires_input?
    form_fields.any? { |field| not field.constant }
  end
  
end
