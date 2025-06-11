class SearchRecipeCreationService
    Result = Struct.new(:success?, :recipe, :error_message, :status)
    def initialize(user:, prompt:, ip_address:, current_session:)
        @user = user
        @prompt = prompt
        @ip_address = ip_address
        @session = current_session
    end

    def call
        # chatGPT API呼び出し
        recipe_response = ChatGptService.new.fetch_recipe(@prompt)

        return Result.new(
            success?: false,
            error_message: "レシピの取得に失敗しました。もう一度お試しください",
            status: :unprocessable_entity
        ) unless recipe_response.present?

        if @user.present?
            # DB保存
            SearchLog.create!(user_id: @user.id, search_time: Time.current)
            recipe = SearchRecipe.create!(
                user: @user,
                query: @prompt,
                search_time: Time.current,
                response_data: recipe_response
            )
            Result.new(success?: true, recipe: recipe)
        else
            # セッション保存
            SearchLog.create!(ip_address: @ip_address, search_time: Time.current)
            @session[:guest_recipe] = recipe_response
            Result.new(success?: true, recipe: nil)
        end

    rescue Net::OpenTimeout, SocketError => e
        Result.new(success?: false, error_message: "外部APIに接続できませんでした。時間をおいて再試行してください。", status: :service_unavailable)

    rescue StandardError => e
        Rails.logger.error("予期しないエラー: #{e.message}")
        Result.new(success?: false, error_message: "予期しないエラーが発生しました。: #{e.message}", status: :unprocessable_entity)
    end
end
