class CreateAssociations < ActiveRecord::Migration
  def self.up
    create_table :associations do |t|
      t.integer :game_id
      t.integer :tag_id

      t.timestamps
    end
    add_index :associations, :game_id
    add_index :associations, :tag_id
  end

  def self.down
    drop_table :associations
  end
end
