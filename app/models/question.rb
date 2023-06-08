class Question < ApplicationRecord
  validates :question, presence: true

  def as_json
    super(only: [:question, :answer, :id])
  end
end
