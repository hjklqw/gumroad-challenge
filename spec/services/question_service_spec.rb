require 'rails_helper'
require './app/services/question_service'

describe QuestionService do
  describe "#initialize" do
    it "sets the service's question to the given argument" do
      service = QuestionService.new('Test?')
      expect(service.question).to eq('Test?')
    end
    
    it "appends a question mark to the given argument if none exists" do
      service = QuestionService.new('Test')
      expect(service.question).to eq('Test?')
    end
  end

  describe "#ask" do
    before do
      @question = create(:question, question: 'Test?')
    end

    context "when a new question is asked" do
      it "returns contents of the question, with answer" do
        new_question = QuestionService::ask('New question?')
        expect(new_question.question).to eq('New question?')
        expect(new_question.answer).not_to be_empty
      end
    end

    context "when an existing question is asked" do
      it "returns that question object" do
        result = QuestionService::ask('Test?')
        expect(result).to eq(@question)
      end
    end

    context "when an existing question is asked with a different case and no question mark" do
      it "returns that question object, with its proper case and question mark" do
        result = QuestionService::ask('tEST')
        expect(result).to eq(@question)
      end
    end
  end

  describe "#get_question" do
    before do
      @question = create(:question, question: 'Test?')
    end

    context "when the ID of an existing question is given" do
      it "returns the question of the given id" do
        result = QuestionService::get_question(@question.id)
        expect(result).to eq(@question)
      end
    end

    context "when the ID of a non-existent question is given" do
      it "raises a not-found exception" do
        expect{
          QuestionService::get_question('invalid-id')
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#get_previously_asked_question" do
    before do
      @saved_question = create(:question, question: 'Test?')
    end

    it "returns the matched question from the DB" do
      service = QuestionService.new('Test?')
      result = service.get_previously_asked_question()
      expect(result).to eq(@saved_question)
    end

    it "adds 1 to the question's ask_count" do
      service = QuestionService.new('Test?')
      expect(service.get_previously_asked_question().ask_count).to eq(2)
      expect(service.get_previously_asked_question().ask_count).to eq(3)
    end

    it "matches case-insensitively" do
      service = QuestionService.new('tEST?')
      result = service.get_previously_asked_question()
      expect(result).to eq(@saved_question)
    end

    it "returns nil when the question is a new one" do
      service = QuestionService.new('New question?')
      result = service.get_previously_asked_question()
      expect(result).to be_nil
    end
  end

  describe "#ask_new_question" do
    let(:service) { QuestionService.new('Hello world') }

    it "creates a new Question in the DB with the retrieved answer and context" do
      service.ask_new_question()
      question = Question.find_by(question: 'Hello world?')
      expect(question).to_not be_nil
      expect(question.answer).to_not be_empty
      expect(question.context).to_not be_empty
    end
  end
end