class Rip < ActiveRecord::Base
  
  has_many :navi_actions
  has_many :bits
  
  validates_uniqueness_of :name
  validates_format_of :start_page, :with => /^http:\/\/.+/
  
end
