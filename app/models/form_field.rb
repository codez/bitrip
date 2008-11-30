class FormField < ActiveRecord::Base
  
  TYPES = [:text, :password, :textarea, :select, :checkbox, :radio]
  
  self.inheritance_column = nil
  
  belongs_to :navi_action
  
  validates_inclusion_of :type, :in => TYPES
  validates_presence_of :name
  
  before_save :empty_non_constant
  
  def type=(val)
    val = val.to_s.downcase if val
    val = 'text' if val == 'text' || 
                     val == 'password'
    val = nil if val == 'hidden' ||
                   val == 'image'          
    write_attribute 'type', val
  end
  
  def type
    val = read_attribute 'type'
    val.to_sym if val
  end  
  
  def value
    val = read_attribute 'value'
    val.nil? ? '' : val
  end
  
  def options_arr
    options ? options.split('<,>') : []
  end
  
  def add_option(value)
    opts = self.options_arr + [value ? value : ' ']
    self.options = opts.join('<,>')
  end
  
  def same?(other)
    self.name == other.name && self.type == other.type
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
