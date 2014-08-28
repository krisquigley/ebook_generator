require 'faker'

FactoryGirl.define do
  factory :section do
    title { Faker::Lorem.sentence(2) }
    content { Faker::Lorem.paragraph(15) }
    sequence(:position)

    book
  end

  factory :ebook do
    title { Faker::Lorem.sentence(5) }
    creator { Faker::Name.name }
    language { "en" }
    contributor { Faker::Name.name }
    description { Faker::Lorem.paragraph(3) }
    publisher { Faker::Name.name }
    rights { Faker::Lorem.paragraph(5) }
    subject { Faker::Lorem.sentence(5) }

    factory :book_with_sections do
      transient do
        sections_count 15
      end

      after(:build) do |book, evaluator|
        create_list(:section, evaluator.sections_count, book: book)
      end
    end
  end
end
