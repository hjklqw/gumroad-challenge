OPENAI_API_KEY = 'OPENAI_API_KEY'

# ===================================================
# Ensure that the OpenAI API key has been given
# ===================================================

if !ENV.has_key?(OPENAI_API_KEY) || ENV[OPENAI_API_KEY].blank?
  raise "Missing required environment variable: #{OPENAI_API_KEY}"
end

# ===================================================
# Ensure that the key is valid
# ===================================================

client = OpenAI::Client.new(access_token: ENV[OPENAI_API_KEY])
response = client.completions(
  parameters: {
    temperature: 0.0,
    max_tokens: 1,
    model: 'text-davinci-003',
    prompt: 'test'
  }
)

if (response['error'])
  raise <<~EOL
    Unable to connect to OpenAI!
    #{response['error']['message']}
  EOL
end