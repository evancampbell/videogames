class AddRelevanceToAssociations < ActiveRecord::Migration
  def self.up
    add_column :associations,:relevance,:integer
  end

  def self.down
    remove_column :associations,:relevance
  end
end
