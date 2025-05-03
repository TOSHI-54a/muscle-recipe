FactoryBot.define do
    factory :search_recipe do
        association :user
        query { '筋肉飯' }
        search_time { Time.current }
        response_data { {}.to_json }
    end
end
