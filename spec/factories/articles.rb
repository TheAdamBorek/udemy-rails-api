FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "My awesome article #{n}" }
    sequence(:content) { |n| "The content of an article #{n}" }
    sequence(:slug) { |n| "my-awesome-article-#{n}" }
  end
end
