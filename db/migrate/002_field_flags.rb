class FieldFlags < ActiveRecord::Migration
  def self.up
    add_column :form_fields, :options, :string
    add_column :form_fields, :required, :boolean, :default => false
    add_column :form_fields, :constant, :boolean, :default => false
    
    add_column :rips, :parent_id, :int
    add_column :rips, :current, :boolean
    add_column :rips, :revision, :int
    add_column :rips, :created_at, :date
    
    create_table :messages do |t|
      t.column :key, :string, :null => false
      t.column :content, :text
    end
  end

  def self.down
    drop_table :messages
    
    remove_column :rips, :parent_id
    remove_column :rips, :current
    remove_column :rips, :revision
    remove_column :rips, :created_at
    
    remove_column :form_fields, :constant   
    remove_column :form_fields, :required  
    remove_column :form_fields, :options  
  end
end
