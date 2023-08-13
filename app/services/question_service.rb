require 'csv'
require 'dotenv/load'
require 'matrix'
require_relative './open_ai_service.rb'

class QuestionService
  attr_reader :question

  # ===================================================
  # Constants
  # ===================================================

  PDF_NAME = ENV['PDF_NAME'] || 'book.pdf'
  CSVS_FOLDER = 'app/assets/csvs'
  private_constant :PDF_NAME, :CSVS_FOLDER

  MAX_CONTENT_LENGTH = 500
  SEPARATOR = "\n* "
  SEPARATOR_LENGTH = SEPARATOR.length
  private_constant :MAX_CONTENT_LENGTH, :SEPARATOR, :SEPARATOR_LENGTH

  PROMPT_HEADER = "Sahil Lavingia is the founder and CEO of Gumroad, and the author of the book The Minimalist Entrepreneur (also known as TME). These are questions and answers by him. Please keep your answers to three sentences maximum, and speak in complete sentences. Stop speaking once your point is made.\n\nContext that may be useful, pulled from The Minimalist Entrepreneur:\n"
  PROMPT_QUESTIONS = [
    "\n\n\nQ: How to choose what business to start?\n\nA: First off don't be in a rush. Look around you, see what problems you or other people are facing, and solve one of these problems if you see some overlap with your passions or skills. Or, even if you don't see an overlap, imagine how you would solve that problem anyway. Start super, super small.",
    "\n\n\nQ: Q: Should we start the business on the side first or should we put full effort right from the start?\n\nA:   Always on the side. Things start small and get bigger from there, and I don't know if I would ever “fully” commit to something unless I had some semblance of customer traction. Like with this product I'm working on now!",
    "\n\n\nQ: Should we sell first than build or the other way around?\n\nA: I would recommend building first. Building will teach you a lot, and too many people use “sales” as an excuse to never learn essential skills like building. You can't sell a house you can't build!",
    "\n\n\nQ: Andrew Chen has a book on this so maybe touché, but how should founders think about the cold start problem? Businesses are hard to start, and even harder to sustain but the latter is somewhat defined and structured, whereas the former is the vast unknown. Not sure if it's worthy, but this is something I have personally struggled with\n\nA: Hey, this is about my book, not his! I would solve the problem from a single player perspective first. For example, Gumroad is useful to a creator looking to sell something even if no one is currently using the platform. Usage helps, but it's not necessary.",
    "\n\n\nQ: What is one business that you think is ripe for a minimalist Entrepreneur innovation that isn't currently being pursued by your community?\n\nA: I would move to a place outside of a big city and watch how broken, slow, and non-automated most things are. And of course the big categories like housing, transportation, toys, healthcare, supply chain, food, and more, are constantly being upturned. Go to an industry conference and it's all they talk about! Any industry…",
    "\n\n\nQ: How can you tell if your pricing is right? If you are leaving money on the table\n\nA: I would work backwards from the kind of success you want, how many customers you think you can reasonably get to within a few years, and then reverse engineer how much it should be priced to make that work.",
    "\n\n\nQ: Why is the name of your book 'the minimalist entrepreneur' \n\nA: I think more people should start businesses, and was hoping that making it feel more “minimal” would make it feel more achievable and lead more people to starting-the hardest step.",
    "\n\n\nQ: How long it takes to write TME\n\nA: About 500 hours over the course of a year or two, including book proposal and outline.",
    "\n\n\nQ: What is the best way to distribute surveys to test my product idea\n\nA: I use Google Forms and my email list / Twitter account. Works great and is 100% free.",
    "\n\n\nQ: How do you know, when to quit\n\nA: When I'm bored, no longer learning, not earning enough, getting physically unhealthy, etc… loads of reasons. I think the default should be to “quit” and work on something new. Few things are worth holding your attention for a long period of time."
    ].join('')
  private_constant :PROMPT_HEADER, :PROMPT_QUESTIONS

  # ===================================================
  # Constructor--is called automatically by self.ask(),
  # and thus does not need to be manually invoked
  # ===================================================

  def initialize(question_asked)
    if (!question_asked.end_with? '?')
      @question = question_asked + '?'
    else
      @question = question_asked
    end
  end

  # ===================================================
  # Public methods
  # ===================================================

  def self.ask(question_asked)
    service = new(question_asked)

    # Check if the question already exists, and returns it if true
    previously_asked_question = service.get_previously_asked_question()
    if previously_asked_question
      return previously_asked_question
    end

    # If false, retrieve the answer from the book encodings or OpenAI,
    # create a new Question entry for it in the DB, then return it
    new_question = service.ask_new_question()
    return new_question
  end

  def self.get_question(id)
    return Question.find(id)
  end

  # ===================================================
  # Helper entry methods
  # Needs to be public for use with self-methods
  # ===================================================

  # Searches for questions in the DB case-insensitively.
  # If there is a match, 1 is added to its ask count before it is returned.
  # @return [Question, nil]
  def get_previously_asked_question
    previously_asked_question = Question.find_by("lower(question) = ?", @question.downcase)
    if previously_asked_question
      previously_asked_question.update(ask_count: previously_asked_question.ask_count + 1)
      previously_asked_question
    end
  end

  def ask_new_question
    answer, context = answer_with_context
    Question.create(question: @question, answer: answer, context: context)
  end

  # ===================================================
  # Private methods
  # ===================================================

  private

  # Use the dot product to get similarity between two vectors.
  # @param x [Array<float>] To be converted into a vector
  # @param y [Array<float>] To be converted into a second vector
  def vector_similarity(x, y)
    vx = Vector.elements(x)
    vy = Vector.elements(y)
    vx.inner_product(vy)
  end

  # Compare the embedding of the question against all of the pre-calculated document embeddings
  # to find the most relevant rows, sorted in descending order.
  # @param document [2D Array] The read-in embeddings CSV with no header row
  # @return [Array<[highest_similarity_value, title], [second_highest_similarity_value, title], [...]>]
  def order_rows_by_query_similarity(document)
    query_embeddings = OpenAiService::get_query_embeddings(@question)

    similarities = []
    for title, *document_embeddings in document do
      document_float_embeddings = document_embeddings.slice(0, query_embeddings.length).map(&:to_f)
      similarities << [vector_similarity(query_embeddings, document_float_embeddings), title]
    end

    similarities.sort_by { |s| -s[0] }
  end

  # Reads a CSV file in the asset directory, with the given name suffix, and drops its header row.
  # @param name_suffix [String] 'embeddings' or 'pages'. Do not add .csv.
  # @returns [Array<[row1_col1, row1_col2], [row2_col1, ...]>] The CSV file as a 2D array.
  def read_csv_file(name_suffix)
    path = Rails.root.join(CSVS_FOLDER, "#{PDF_NAME}.#{name_suffix}.csv")
    CSV.read(path).drop(1)
  end

  # Get the contents of the Embeddings CSV, as well as the Pages CSV (transformed into a hash.)
  def get_csv_data
    embeddings = read_csv_file('embeddings')
    pages = read_csv_file('pages')

    page_rows = pages.map { |row| {
      :title => row[0],
      :content => row[1],
      :num_tokens => row[2].to_i
    } }

    return embeddings, page_rows
  end

  def construct_prompt
    embeddings, page_rows = get_csv_data()
    most_relevant_rows = order_rows_by_query_similarity(embeddings)

    chosen_contents = []
    chosen_titles = []
    chosen_content_length = 0

    for _similarity, title in most_relevant_rows do
      page_row = page_rows.find { |row| row[:title] == title }
      chosen_content_length += page_row[:num_tokens] + SEPARATOR_LENGTH

      if chosen_content_length > MAX_CONTENT_LENGTH
        space_left = chosen_content_length - SEPARATOR_LENGTH - MAX_CONTENT_LENGTH
        chosen_contents << SEPARATOR + page_row[:content].slice(0, space_left)
        chosen_titles << title
        break
      end

      chosen_contents << SEPARATOR + page_row[:content]
      chosen_titles << title
    end

    flattened_contents = chosen_contents.join('')
    prompt = PROMPT_HEADER + flattened_contents + PROMPT_QUESTIONS + "\n\n\nQ: " + @question + "\n\nA: "
    context = flattened_contents

    return prompt, context
  end

  def answer_with_context
    prompt, context = construct_prompt()
    answer = OpenAiService::get_completion(prompt)

    return answer, context
  end

end
