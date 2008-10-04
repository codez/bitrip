class FormField < ActiveRecord::Base
  
  TYPES = [:text, :password, :textarea, :select, :checkbox, :radio]
  
  self.inheritance_column = nil
  
  belongs_to :navi_action
  
  validates_inclusion_of :type, :in => TYPES
  validates_presence_of :name
  
  before_save :empty_non_constant
  
  def type=(value)
    value = value.to_s.downcase if value
    value = 'text' if value == 'text' || 
                     value == 'password'
    value = nil if value == 'hidden' ||
                   value == 'image'          
    write_attribute 'type', value
  end
  
  def type
    value = read_attribute 'type'
    value.to_sym if value
  end  
  
  def control
    case type
      when :text then :text_field
      when :password then :password_field
      when :textarea then :text_area
      when :select then :collection_select
      when :radio then :radio_button
      when :checkbox then :check_box
    end  
  end
  
  def empty_non_constant
    self.value = nil if not constant
  end
  
end
