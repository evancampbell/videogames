class AddDefaultToAssociations < ActiveRecord::Migration
  def self.up
    change_column_default :associations,:relevance,0
  end

  def self.down
    remove_column :associations,:relevance
  end
end
