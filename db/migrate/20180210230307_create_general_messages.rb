class CreateGeneralMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :general_messages do |t|
      t.string :body
      t.string :number
    end
  end
end
