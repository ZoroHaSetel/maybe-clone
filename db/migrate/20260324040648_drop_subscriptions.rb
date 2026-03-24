class DropSubscriptions < ActiveRecord::Migration[7.2]
  def change
    drop_table :subscriptions
  end
end
