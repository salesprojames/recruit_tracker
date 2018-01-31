class CreateRecruits < ActiveRecord::Migration[5.1]
  def change
    create_table :recruits do |t|
      t.string :name
      t.string :phone_number
      t.string :email
      t.text :description
      t.date :start_date
      t.boolean :closed, default: false
    end
  end
end
