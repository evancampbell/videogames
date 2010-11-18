class ChangeTypeOfName < ActiveRecord::Migration
  def self.up
    rename_column :tags,:type_of,:type_id
  end

  def self.down
  end
end
