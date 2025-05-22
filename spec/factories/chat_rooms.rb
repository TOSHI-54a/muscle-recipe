FactoryBot.define do
    factory :chat_room do
        room_type { "private" }

        trait :private_with_users do
            transient do
                user_a { create(:user) }
                user_b { create(:user) }
            end

            after(:create) do |chat_room, evaluator|
                chat_room.users << evaluator.user_a
                chat_room.users << evaluator.user_b
                chat_room.update!(unique_key: [ evaluator.user_a.id, evaluator.user_b.id ].sort.join("-"))
            end
        end

        trait :group_with_users do
            room_type { "group" }
            transient do
                users { create_list(:user, 3) }
            end

            after(:create) do |chat_room, evaluator|
                chat_room.users << evaluator.users
                chat_room.update!(name: "Test Group")
            end
        end
    end
end
