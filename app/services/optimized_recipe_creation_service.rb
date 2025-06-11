class OptimizedRecipeCreationService
    Result = Struct.new(:success?, :recipe, :error_message, :status)
    def initialize(user:, params:, ip_address:, current_session:)
        @user = user
        @params = params
        @ip_address = ip_address
        @session = current_session
    end

    def call
        fastapi_response = fetch_from_fastapi
        return Result.new(success?: false, error_message: "FastAPI通信エラー", status: 500) unless fastapi_response

        prompt = FastapiPromptBuilder.build(fastapi_response)
        recipe_response = ChatGptService.new.fetch_pfc_prompt(prompt)
        return Result.new(success?: false, error_message: "ChatGPT応答エラー", status: 422) unless recipe_response.present?

        if @user
            SearchLog.create!(user_id: @user.id, search_time: Time.current)
            recipe = SearchRecipe.create!(
                user: @user,
                query: prompt,
                search_time: Time.current,
                response_data: recipe_response
            )
            Result.new(success?: true, recipe: recipe)
        else
            SearchLog.create!(ip_address: @ip_address, search_time: Time.current)
            @session[:guest_recipe] = recipe_response
            Result.new(success?: true, recipe: nil)
        end
    rescue => e
        Rails.logger.error("OptimizedRecipeCretionService Error: #{e.message}")
        Result.new(success?: false, error_message: "予期しないエラーが発生しました", status: 500)
    end

    private

    def fetch_from_fastapi
        uri = URI(ENV.fetch("FASTAPI_URL", "http://fastapi:8000/suggest_recipe"))
        req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
        req.body = {
            target_p: safe_float(@params[:target_p]),
            target_f: safe_float(@params[:target_f]),
            target_c: safe_float(@params[:target_c])
        }.to_json

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
            # FastAPIサーバーに送信
            http.request(req)
        end

        JSON.parse(res.body)
    rescue => e
        Rails.logger.error("FastAPI リクエストエラー：#{e.message}")
        nil
    end

    def safe_float(value)
        Float(value)
    rescue ArgumentError, TypeError
        nil
    end
end
