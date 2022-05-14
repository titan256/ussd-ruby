class AddNetworkCodeToSession < ActiveRecord::Migration[6.1]
  def change
    add_column :sessions, :network_code, :integer
  end
end
