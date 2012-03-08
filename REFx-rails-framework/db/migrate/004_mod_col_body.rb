class ModColBody < ActiveRecord::Migration
  def self.up
	change_column( :jobs, :body, :text, :limit => 16777216 )
  end

  def self.down
	change_column( :jobs, :body, :text )
  end
end
