class AddChildrenToTags < ActiveRecord::Migration
  def self.up
    add_column :tags,:children,:integer
  end

  def self.down
    remove_column :tags,:children
  end
end
