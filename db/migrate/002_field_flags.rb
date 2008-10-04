class FieldFlags < ActiveRecord::Migration
  def self.up
    add_column :form_fields, :options, :string
    add_column :form_fields, :required, :boolean, :default => false
    add_column :form_fields, :constant, :boolean, :default => false
  end

  def self.down
    remove_column :form_fields, :constant   
    remove_column :form_fields, :required  
    remove_column :form_fields, :options  
  end
end
