class CreateSessions < ActiveRecord::Migration[5.1]
  def change
    create_table :sessions do |t|
      t.string :provider_session_id
      t.string :page_ref
      t.string :msisdn
      t.json :data
      t.string :provider_key
      t.string :instance_key

      t.timestamps
    end
  end
end
