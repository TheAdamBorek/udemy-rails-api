FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "Login #{n}" }
    name { "Name" }
    url { "https://fakeimg.pl/200x200" }
    avatar_url { "https://fakeimg.pl/200x200" }
    provider { "github" }
  end
end
