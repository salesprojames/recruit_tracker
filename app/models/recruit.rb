class Recruit < ApplicationRecord

  has_many :tasks, inverse_of: :recruit
  accepts_nested_attributes_for :tasks

  default_scope -> { order(closed: :asc) }
  default_scope -> {
    joins(:tasks).order("tasks.due_date")
  }

end
