class AddThemeTypeToTags < ActiveRecord::Migration
  def self.up
    add_column :tags,:theme_type,:integer
  end

  def self.down
    remove_column :tags,:theme
  end
end
