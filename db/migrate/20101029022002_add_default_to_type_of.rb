class AddDefaultToTypeOf < ActiveRecord::Migration
  def self.up
    change_column_default :games,:type_of,0
  end

  def self.down
  end
end
