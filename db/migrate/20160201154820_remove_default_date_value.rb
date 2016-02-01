class RemoveDefaultDateValue < ActiveRecord::Migration
  def change
    change_column_default(:events, :date, nil)
  end
end
