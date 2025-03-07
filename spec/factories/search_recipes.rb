FactoryBot.define do
    factory :search_recipe do
        association :user
        query { 'チキンカレー' }
        search_time { Time.current }
        response_data { { "recipe" => { "title" => "テストレシピ", "description" => "簡単な説明" } } }
    end
end
