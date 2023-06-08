# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Question.create([
  {
    question: 'What is The Minimalist Entrepreneur about?',
    answer: 'The Minimalist Entrepreneur is a book about how to start and grow a business with less stress and fewer resources. It covers topics like how to choose what business to start, how to build and sell your product, and how to manage your time and money.'
  },
  {
    question: 'How to choose what business to start?',
    answer: 'Look around you, identify problems that need solving, and see if you have the skills or passions to solve them. Start small and build from there. Don\'t rush into anything.'
  },
  {
    question: 'Should we start the business on the side first or should we put full effort right from the start?',
    answer: 'Always start on the side. Start small and build up gradually. Don\'t commit too much time or resources until you have some customer traction.'
  },
])
