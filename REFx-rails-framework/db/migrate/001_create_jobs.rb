class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.integer :priority
      t.string :engine
      t.text :body
      t.integer :status # 1 new,  10 finished, 20, error

      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
