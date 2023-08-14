require 'rails_helper'
require './app/controllers/api/question_controller'

describe Api::QuestionController do
  before do
    @question = create(:question)
  end

  describe "#get" do
    context "when the ID of an existing question is given" do
      it "returns the question of the given id" do
        get :get, params: { :id => @question.id }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(@question.as_json)
      end
    end

    context "when the ID of a non-existent question is given" do
      it "raises a not-found exception" do
        expect{
          get :get, params: { :id => 'invalid-id' }
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#ask" do
    context "when a new question is asked" do
      it "returns contents of the question, with answer" do
        get :ask, params: { :question => 'New question?' }
        expect(response.status).to eq(200)

        new_question = JSON.parse(response.body)
        expect(new_question['question']).to eq('New question?')
        expect(new_question['answer']).not_to be_empty
      end
    end

    context "when an existing question is asked" do
      it "returns that question object" do
        get :ask, params: { :question => @question.question }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(@question.as_json)
      end
    end

    context "when an existing question is asked with a different case and no question mark" do
      it "returns that question object, with its proper case and question mark" do
        reformatted_question = @question.question.downcase.chop
        get :ask, params: { :question => reformatted_question }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(@question.as_json)
      end
    end
  end
end