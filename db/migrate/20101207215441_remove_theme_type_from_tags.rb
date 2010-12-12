class RemoveThemeTypeFromTags < ActiveRecord::Migration
  def self.up
    remove_column :tags,:theme_type
  end

  def self.down
  end
end
