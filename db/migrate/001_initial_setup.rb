class InitialSetup < ActiveRecord::Migration
  def self.up
    create_table :rips do |t|
      t.column :name, :string, :null => false
      t.column :description, :string
      t.column :start_page, :string, :null => false
    end
    
    create_table :bits do |t|
      t.column :label, :string
      t.column :xpath, :string, :null => false
      t.column :generalize, :boolean, :default => true
      t.column :rip_id, :int, :null => false
      t.column :position, :int
    end
    
    create_table :navi_actions do |t|
      t.column :type, :string
      t.column :rip_id, :int, :null => false
      t.column :position, :int 
      t.column :link_text, :string
    end
    
    create_table :form_fields do |t|
      t.column :type, :string, :null => false
      t.column :name, :string, :null => false
      t.column :value, :string
      t.column :navi_action_id, :int, :null => false
    end
  end

  def self.down
    drop_table :form_fields
    drop_table :navi_actions
    drop_table :bits
    drop_table :rips
  end
end
