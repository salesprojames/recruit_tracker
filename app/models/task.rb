class Task < ApplicationRecord
	default_scope -> { order(due_date: :desc) }

  belongs_to :recruit, inverse_of: :tasks, dependent: :destroy
end
