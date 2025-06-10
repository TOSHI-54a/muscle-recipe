class GuestUser
    include ActiveModel::Model

    attr_reader :id, :user_id, :query, :search_time, :response_data

    def initialize(query: nil, response_data: nil)
        @id = nil
        @user_id = nil
        @query = query
        @search_time = Time.current
        @response_data = response_data
    end
end
