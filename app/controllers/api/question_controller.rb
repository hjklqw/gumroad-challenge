class Api::QuestionController < ApplicationController
  def get
    question = Question.find(params[:id])
    render json: question.as_json
  end
end
