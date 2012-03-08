class AddReturnbodyToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :returnbody, :text
  end

  def self.down
    remove_column :jobs, :returnbody
  end
end
