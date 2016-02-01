class RemoveOtherDefaults < ActiveRecord::Migration
  def change
    change_column_default(:events, :message, nil)
    change_column_default(:events, :otheruser, nil)
    change_column_default(:events, :user, nil)
    change_column_default(:events, :type, nil)
  end
end
