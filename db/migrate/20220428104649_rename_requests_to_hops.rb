class RenameRequestsToHops < ActiveRecord::Migration[6.1]
  def change
    rename_table :requests, :hops
  end
end
