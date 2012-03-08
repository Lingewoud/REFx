class Mod1Jobs < ActiveRecord::Migration
  def self.up
	  add_column :jobs, :max_attempt, :integer
	  add_column :jobs, :attempt, :integer
  end

  def self.down
  end
end
