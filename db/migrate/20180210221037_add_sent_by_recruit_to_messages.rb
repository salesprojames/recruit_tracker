class AddSentByRecruitToMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :sent_by_recruit, :boolean, default: false
  end
end
