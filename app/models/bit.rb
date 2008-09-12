class Bit < ActiveRecord::Base
  
  act_as_list :scope => :rip
  
  belongs_to :rip
  
  validates_presence_of :xpath
  
  
end
