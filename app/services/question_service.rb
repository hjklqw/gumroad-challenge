class QuestionService
  def self.get_question(id)
    return Question.find(id)
  end
end
