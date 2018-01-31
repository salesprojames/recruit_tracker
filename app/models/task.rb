class Task < ApplicationRecord
	default_scope -> { order(due_date: :desc) }

  belongs_to :recruit
end
