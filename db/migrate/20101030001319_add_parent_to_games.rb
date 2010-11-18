class AddParentToGames < ActiveRecord::Migration
  def self.up
    add_column :games,:parent,:integer
  end

  def self.down
    remove_column :games,:parent
  end
end
