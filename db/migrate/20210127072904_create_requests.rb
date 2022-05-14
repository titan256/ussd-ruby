class CreateRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :requests do |t|
      t.references :session, foreign_key: true
      t.string :input
      t.string :response

      t.timestamps
    end
  end
end
