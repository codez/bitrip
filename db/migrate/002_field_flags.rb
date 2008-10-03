class FieldFlags < ActiveRecord::Migration
  def self.up
    add_column :form_fields, :constant, :boolean, :default => false
  end

  def self.down
    remove_column :form_fields, :constant    
  end
end
