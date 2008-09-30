class NaviAction < ActiveRecord::Base

  TYPES = [:form, :link]

  has_many :form_fields, :dependent => :destroy
  
  validates_inclusion_of :type, :in => TYPES
  validates_presence_of :link_text, :if => Proc.new {|navi_action| navi_action.type == :link }

end
