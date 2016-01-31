class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :user, :default => ""
      t.string :type, :default => ""
      t.string :message, :default => ""
      t.string :otheruser, :default => ""
      t.datetime :date, :default => Time.now

      t.timestamps
    end
  end
end
