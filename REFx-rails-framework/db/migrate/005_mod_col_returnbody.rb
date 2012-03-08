class ModColReturnbody < ActiveRecord::Migration
  def self.up
	change_column( :jobs, :returnbody, :text, :limit => 16777216 )
  end

  def self.down
	change_column( :jobs, :returnbody, :text )
  end
end
