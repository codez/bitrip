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
  
  def select_indizes_array
    parts = select_indizes.split(',')
    parts.collect! do |p|
      puts p.strip
      case p.strip
        when /^([0-9]+)$/             then Integer($1)
        when /^([0-9]+)\.\.([0-9]+)$/ then puts $1; puts $2; (Integer($1)+1)..(Integer($2)+1)
        when /^([A-Za-z]\w*)$/        then $1.to_sym
        else nil
      end    
    end
    p parts
    parts.select { |p| not p.nil? }
  end
  
private

  def last_slash_xpath
    xpath.rindex('/') if xpath
  end  
end
