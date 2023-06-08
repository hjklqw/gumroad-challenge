require 'optparse'
require 'csv'
require 'openai'
require 'dotenv/load'
require 'pdf-reader'
require 'tokenizers'

# ===================================================
# Shared variables
# ===================================================

# The name of the PDF file to read
$pdfName = ENV['PDF_NAME'] || ''

# Stores the data (sans token count) of the Pages CSV that will be generated,
# for use when generating embeddings.
$generated_page_csv_data = []

# ===================================================
# Get the PDF name from command line args
# ===================================================

OptionParser.new do |parser|
  parser.on('--pdf PDF', 'Name of PDF') do |pdf|
    $pdfName = pdf
  end
 end.parse!

 # Exit with an error message if no name was given
if $pdfName == ''
    $stderr.print('Missing argument: --pdf')
    exit 1
end

# ===================================================
# Ensure that the file exists
# ===================================================

if (!File.exist?($pdfName))
  $stderr.print("A file with the name \"#{$pdfName}\" does not exist.")
  exit 1
end

# ===================================================
# Generate a Pages CSV from the given PDF
# ===================================================

$tokenizer = Tokenizers.from_pretrained('gpt2')

def extract_page_to_row(page_text, page_num)
  if (page_text.length == 0)
    return []
  end

  title = "Page #{page_num}"
  flattened_content = page_text.split().join(' ')
  num_tokens = $tokenizer.encode(flattened_content).tokens.length + 4
  $generated_page_csv_data << { :title => title, :content => flattened_content }
  return [title, flattened_content, num_tokens]
end

def generate_pages
  reader = PDF::Reader.new($pdfName)

  rows = []
  page_num = 1

  reader.pages.each do |page|
    rows << extract_page_to_row(page.text, page_num)
    page_num += 1
  end

  CSV.open("#{$pdfName}.pages.csv", 'wb') do |csv|
    csv << ['title', 'content', 'tokens']
    rows.each do |row|
      csv << row
    end
  end
end

# ===================================================
# Generate a Pages CSV from the given PDF
# ===================================================

$client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

DOC_EMBEDDINGS_MODEL = 'text-search-curie-doc-001'
EMBEDDING_LENGTH = 4096

def get_embeddings_for_page(text)
  response = $client.embeddings(
    parameters: {
      model: DOC_EMBEDDINGS_MODEL,
      input: text
    }
  )

  return response['data'][0]['embedding']
end

def generate_embeddings
  rows = []
  for row in $generated_page_csv_data do
    rows << [row[:title], get_embeddings_for_page(row[:content])]
  end

  CSV.open("#{$pdfName}.embeddings.csv", 'wb') do |csv|
    csv << ['title'] + Array.new(EMBEDDING_LENGTH) { |i| i }
    rows.each do |row|
      csv << row.flatten
    end
  end
end

# ===================================================
# Script entry point
# ===================================================

puts "Generating pages..."
generate_pages()

puts "Generating embeddings..."
generate_embeddings()

puts "Done!"