class FormField < ActiveRecord::Base
  
  validates_inclusion_of :type, :in => [:text, :textarea, :select, :checkbox, :radio]
  validates_presence_of :name
  
end
