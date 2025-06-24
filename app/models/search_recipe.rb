class SearchRecipe < ApplicationRecord
    belongs_to :user, optional: true
    has_many :likes, dependent: :destroy
    has_many :liked_users, through: :likes, source: :user

    validates :query, presence: true
    validates :search_time, presence: true

    def parsed_response_data
        response_data.is_a?(String) ? JSON.parse(response_data) : response_data
    end

    # JSONBカラムをransackで検索可能にする
    ransacker :recipe_title, formatter: proc { |v| v.downcase } do
        Arel.sql("LOWER(response_data->'recipe'->>'title')")
    end

    # ransackの検索可能なカラムを定義（ホワイトリスト）
    def self.ransackable_attributes(auth_object = nil)
        [ "created_at", "id", "query", "response_data", "search_time", "updated_at", "user_id", "recipe_title" ]
    end

    # ransackの関連モデルの検索許可
    def self.ransackable_associations(auth_object = nil)
        [ "user" ]
    end
end
