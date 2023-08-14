require 'rails_helper'
require './app/services/open_ai_service'

EMBEDDINGS_RESPONSE_STRUCTURE = {
  'data' => [{ 'embedding' => 'test' }]
}

describe OpenAiService do
  let(:mock_openai_client) { double("openai") }

  before do
    OpenAiService.class_variable_set(:@@client, mock_openai_client)
  end

  describe "#get_completion" do
    it "passes the correct parameters to the completions client, and returns the result from the correct property with leading and trailing whitespace removed" do
      expect(mock_openai_client).to receive(:completions).with({
        parameters: {
          temperature: 0.0,
          max_tokens: 150,
          model: 'text-davinci-003',
          prompt: 'text'
        }
      }).and_return({
        'choices' => [{ 'text' => '  test   ' }]
      })
      result = OpenAiService::get_completion('text')
      expect(result).to eq('test')
    end
  end

  describe "#get_query_embeddings" do
    it "passes the query model and input to the embeddings client, and returns the result from the correct property" do
      expect(mock_openai_client).to receive(:embeddings).with({
        parameters: {
          model: 'text-search-curie-query-001',
          input: 'text'
        }
      }).and_return(EMBEDDINGS_RESPONSE_STRUCTURE)
      result = OpenAiService::get_query_embeddings('text')
      expect(result).to eq('test')
    end
  end

  describe "#get_doc_embeddings" do
    it "passes the document model and input to the embeddings client, and returns the result from the correct property" do
      expect(mock_openai_client).to receive(:embeddings).with({
        parameters: {
          model: 'text-search-curie-doc-001',
          input: 'text'
        }
      }).and_return(EMBEDDINGS_RESPONSE_STRUCTURE)
      result = OpenAiService::get_doc_embeddings('text')
      expect(result).to eq('test')
    end
  end
end