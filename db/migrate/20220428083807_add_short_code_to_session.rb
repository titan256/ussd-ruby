class AddShortCodeToSession < ActiveRecord::Migration[6.1]
  def change
    add_column :sessions, :short_code, :string
  end
end
