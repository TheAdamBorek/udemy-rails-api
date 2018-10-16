FactoryBot.define do
  factory :access_token do
    # token is create at the init
    association :user
  end
end
