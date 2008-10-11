class Bit < ActiveRecord::Base
  
  belongs_to :rip
  acts_as_list :scope => :rip_id
  
  validates_presence_of :xpath
  validates_uniqueness_of :position, :scope => :rip_id
  
  attr_accessor :snippets
  
  def img?
    xpath[last_slash_xpath, 4].downcase == '/img'
  end
  
  def xpath_scrubyt
    img? ? xpath[0,last_slash_xpath] : xpath
  end
  
private

  def last_slash_xpath
    xpath.rindex('/') if xpath
  end  
end
