FactoryBot.define do
    factory :user do
      name { Faker::Name.name }
      email { Faker::Internet.unique.email }
      password { 'password' }
      password_confirmation { 'password' }

      trait :with_google do
        email { "test@example.com" }
        provider { "google" }
        uid { "12345" }
      end
    end
  end
