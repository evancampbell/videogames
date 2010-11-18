class RemoveTypesFromTags < ActiveRecord::Migration
  def self.up
    remove_column :tags,:type
  end

  def self.down
    add_column :tags,:type,:integer
  end
end
