class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string :name,  :null => false
      t.string :brand, :limit => 16

      t.timestamps
    end
  end

  def self.down
    drop_table :sites
  end
end
