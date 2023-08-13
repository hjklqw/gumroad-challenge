require "rails_helper"
require './app/models/question'

describe Question do
  it "should not save without question" do
    question = Question.new
    expect(question).to_not be_valid
  end
end