class Indizes < ActiveRecord::Migration
  def self.up
    add_index :messages, :key, :unique => true
    add_index :rips, [:name, :current]
    add_index :navi_actions, :rip_id
    add_index :form_fields, :navi_action_id
    add_index :bits, :rip_id

    execute "ANALYZE messages"
    execute "ANALYZE rips"
    execute "ANALYZE navi_actions"
    execute "ANALYZE form_fields"
    execute "ANALYZE bits"
  end

  def self.down
    remove_index :bits, :rip_id
    remove_index :form_fields, :navi_action_id
    remove_index :navi_actions, :rip_id
    remove_index :rips, :name
    remove_index :messages, :key
  end
end
