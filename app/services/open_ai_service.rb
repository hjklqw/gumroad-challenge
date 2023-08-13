require 'openai'

class OpenAiService

  @@client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

  EMBEDDINGS_MODEL_NAME = 'curie'
  DOC_EMBEDDINGS_MODEL = "text-search-#{EMBEDDINGS_MODEL_NAME}-doc-001"
  QUERY_EMBEDDINGS_MODEL = "text-search-#{EMBEDDINGS_MODEL_NAME}-query-001"
  private_constant :EMBEDDINGS_MODEL_NAME, :DOC_EMBEDDINGS_MODEL, :QUERY_EMBEDDINGS_MODEL

  COMPLETIONS_MODEL = 'text-davinci-003'
  COMPLETIONS_API_PARAMS = {
      # We use temperature of 0.0 because it gives the most predictable, factual answer.
      temperature: 0.0,
      max_tokens: 150,
      model: COMPLETIONS_MODEL,
  }
  private_constant :COMPLETIONS_MODEL, :COMPLETIONS_API_PARAMS

  def self.get_completion(text)
    newParams = {
      prompt: text
    }
    response = @@client.completions(
      parameters: newParams.merge(COMPLETIONS_API_PARAMS)
    )
    response['choices'][0]['text'].strip()
  end

  def self.get_embeddings(model, text)
    response = @@client.embeddings(
      parameters: {
        model: model,
        input: text
      }
    )
    response['data'][0]['embedding']
  end

  def self.get_query_embeddings(text)
    self.get_embeddings(QUERY_EMBEDDINGS_MODEL, text)
  end

  def self.get_doc_embeddings(text)
    self.get_embeddings(DOC_EMBEDDINGS_MODEL, text)
  end

  class << self
    private :get_embeddings
  end

end
