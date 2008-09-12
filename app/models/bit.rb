class Bit < ActiveRecord::Base
  
  belongs_to :rip
  acts_as_list :scope => :rip
  
  validates_presence_of :xpath
  validates_uniqueness_of :position, :scope => :rip
  
  
end
