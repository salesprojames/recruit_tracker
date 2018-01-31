class Recruit < ApplicationRecord
	default_scope -> { order(start_date: :desc) }

  has_many :tasks
end
