class Bit < ActiveRecord::Base
  
  belongs_to :rip
  acts_as_list :scope => :rip_id
  
  validates_presence_of :xpath
  validates_uniqueness_of :position, :scope => :rip_id
  
  def xpath
    value = read_attribute 'xpath'
    value.empty? ? '/' : value 
  end
end
