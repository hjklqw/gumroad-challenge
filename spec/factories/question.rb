FactoryBot.define do
  factory :question, class: "Question" do
    question { Faker::Lorem.question }
    answer { Faker::GreekPhilosophers.quote }
  end
end