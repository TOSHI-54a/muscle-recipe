class SearchesController < ApplicationController
  before_action :check_search_limit, only: :create
  before_action :set_show, only: %i[show destroy]
  skip_before_action :authenticate_user!, only: %i[ new create show ]

  def new
    @search_recipes = SearchRecipe.new
    @user = current_user
    @guest_recipe = session[:guest_recipe]
    session.delete(:guest_recipe)
  end

  def show; end

  def index
  end

  def create
    # Rails.logger.debug "Received !params: #{params.inspect}"

    prompt = recipe_params
    # Rails.logger.debug "Filtered !params: #{prompt.inspect}"

    recipe_response = ChatGptService.new.fetch_recipe(prompt)
    # Rails.logger.debug "ChatGPT API Response: #{recipe_response.inspect}"
    if recipe_response.present?
      if current_user
        @show_recipe = SearchRecipe.create!(
          user: current_user,
          query: prompt,
          search_time: Time.current,
          response_data: recipe_response
        )

        # Rails.logger.debug "保存後のSearchRecipe: #{@show_recipe.inspect}"
        # Rails.logger.debug "保存後のresponse_data: #{@show_recipe.response_data.inspect}"

        # @recommendation = recipe_response
        redirect_to search_path(@show_recipe)
      else
        session[:guest_recipe] = recipe_response
        flash.now[:notice] = "レシピは保存されません。"
        redirect_to new_search
      end
    else
      Rails.logger.debug("ChatGPT APIからのレスポンスが無効: #{recipe_response.inspect}")
      flash[:error] = "レシピの取得に失敗しました。もう一度お試しください。"
      render :new, status: :unprocessable_entity
    end
  # render json: { recipe: recipe_response }, status: ok
  rescue => e
    # Rails.logger.debug "Recipe response is empty or invalid: #{@recommendations.inspect}"
    Rails.logger.debug "Error in create action: #{e.message}"
    flash[:error] = 'レシピの取得に失敗しました: #{e.message}'
    render :new, status: :unprocessable_entity
    # render json: { error: e.message }, status: :internal_server_error
  end

  def saved
    @q = current_user.search_recipes.ransack(params[:q])
    @saved_recipes = @q.result(distinct: true).order(created_at: :desc)
    # @saved_recipes = current_user.search_recipes.order(created_at: :desc)
  end

  def destroy
    if @show_recipe.destroy!
      flash[:success] = "削除成功!"
      redirect_to saved_searches_path, success: "削除成功！!!!"
    else
      render :saved, status: :unprocessable_entity
    end
  end


  private

  def check_search_limit
    if current_user
      search_count = SearchLog.where(user_id: current_user.id, search_time: Date.current.all_day).count
      max_limit = 100
    else
      search_count = SearchLog.where(ip_address: request.remote_ip, search_time: Date.current.all_day).count
      max_limit = 100
    end

    if search_count >= max_limit
      flash[:alert] = "1日に検索できる回数を超えました。"
      render json: { status: "error", message: "Search limit reached for today" }, status: 403
    end
  end

  def recipe_params
    params.require(:user).permit(
      :recipe_complexity,
      :seasonings,
      body_info: [ :age, :gender, :height, :weight ],
      ingredients: [ :use, :avoid ],  # 配列ではなく文字列として受け取る
      available: [ :name, :amount ],  # available を ingredients から独立
      preferences: [ :goal, :calorie_and_pfc ]
    ).to_h
  end

  def set_show
    @show_recipe = SearchRecipe.find(params[:id])
  end
end
