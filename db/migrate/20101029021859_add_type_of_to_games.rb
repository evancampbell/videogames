class AddTypeOfToGames < ActiveRecord::Migration
  def self.up
    add_column :games,:type_of,:integer
  end

  def self.down
    remove_column :games,:type_of
  end
end
