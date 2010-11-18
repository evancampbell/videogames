class AddTypeToTags < ActiveRecord::Migration
  def self.up
    add_column :tags,:type,:integer
  end

  def self.down
    remove_column :tags,:type
  end
end
