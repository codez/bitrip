class NextPages < ActiveRecord::Migration
  def self.up
    add_column :rips, :next_pages, :int
    add_column :rips, :next_link, :string
    add_column :bits, :select_indizes, :string
  end

  def self.down
    remove_column :bits, :select_indizes
    remove_column :rips, :next_link
    remove_column :rips, :next_pages
  end
end
