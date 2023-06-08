class Api::QuestionController < ApplicationController
  def get
    question = QuestionService::get_question(params[:id])
    render json: question.as_json
  end
end
