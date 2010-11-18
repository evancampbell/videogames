class AddParentToTags < ActiveRecord::Migration
  def self.up
    add_column :tags,:parent,:integer
  end

  def self.down
    remove_column :tags,:parent
  end
end
