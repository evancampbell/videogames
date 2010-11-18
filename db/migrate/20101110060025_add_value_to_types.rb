class AddValueToTypes < ActiveRecord::Migration
  def self.up
    add_column :types,:value,:integer
  end

  def self.down
    remove_column :types,:value
  end
end
