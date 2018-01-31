class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.date :due_date
      t.string :name
      t.integer :recruit_id
    end
  end
end
