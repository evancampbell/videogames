class AddDefaultToChildren < ActiveRecord::Migration
  def self.up
    change_column_default :tags,:children,0
  end

  def self.down
  end
end
