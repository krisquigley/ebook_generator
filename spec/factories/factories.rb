require 'faker'

FactoryGirl.define do
  title = Faker::Lorem.sentence(5)

  factory :section do
    title { Faker::Lorem.sentence(2) }
    content { Faker::Lorem.paragraph(15) }
    sequence(:position)

    ebook
  end

  factory :ebook do
    title { title }
    creator { Faker::Name.name }
    language { "en" }
    contributor { Faker::Name.name }
    description { Faker::Lorem.paragraph(3) }
    publisher { Faker::Name.name }
    rights { Faker::Lorem.paragraph(5) }
    subject { Faker::Lorem.sentence(5) }
    slug { title.gsub(' ', '-') }

    factory :ebook_with_sections do
      ignore do
        sections_count 15
      end

      after(:create) do |ebook, evaluator|
        FactoryGirl.create_list(:section, evaluator.sections_count, ebook: ebook)
      end
    end
  end
end
