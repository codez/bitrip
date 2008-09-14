class Rip < ActiveRecord::Base
  
  has_many :navi_actions, :order => 'position', :dependent => :destroy
  has_many :bits, :order => 'position', :dependent => :destroy
  
  validates_uniqueness_of :name
  validates_format_of :start_page, :with => /^https?:\/\/.+/
  
end
