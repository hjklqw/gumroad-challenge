require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  test "should not save without question" do
    question = Question.new
    assert_not(question.save, "Saved without a question")
  end
end
