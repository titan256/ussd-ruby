class SessionsIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index(:sessions, [:provider_session_id, :provider_key], unique: true)
    add_index(:sessions, :msisdn)
    add_index(:sessions, :created_at)
  end
end
