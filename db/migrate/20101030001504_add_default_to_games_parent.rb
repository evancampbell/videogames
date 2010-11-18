class AddDefaultToGamesParent < ActiveRecord::Migration
  def self.up
    change_column_default :games,:parent,0
  end

  def self.down
  end
end
