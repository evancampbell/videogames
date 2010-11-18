class RenameTypeInTags < ActiveRecord::Migration
  def self.up
    rename_column :tags,:type,:type_of
  end

  def self.down
  end
end
