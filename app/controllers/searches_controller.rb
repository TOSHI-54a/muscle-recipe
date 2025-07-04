require "net/http"
require "json"

class SearchesController < ApplicationController
  before_action :search_count, only: %i[ new create optimized ]
  before_action :check_search_limit, only: %i[ create optimized ]
  before_action :set_show, only: %i[show destroy]
  skip_before_action :authenticate_user!, only: %i[ new create show optimized ]

  def new
    @search_recipes = SearchRecipe.new
    if current_user
      @user = current_user
      # PFCレシピ検索のTDEE表示用
      if current_user&.age && current_user&.height && current_user&.weight && current_user&.gender
        @pfc_data = PfcCalculator.calculate(
          age: current_user.age,
          height: current_user.height,
          weight: current_user.weight,
          gender: current_user.gender,
          activity_level: 1.75
        )
      end
    else
      flash[:error] = "⚠️注意：ゲストの検索回数は1日1回です！"
      if session[:guest_recipe]
        @user = GuestUser.new(
          query: session[:guest_recipe][:query],
          response_data: session[:guest_recipe]
        )
        @guest_recipe = @user
      else
        @user = GuestUser.new
      end
    end
    session.delete(:guest_recipe)
  end

  def show; end

  def index; end

  def create
    prompt = recipe_params.to_json
    result = SearchRecipeCreationService.new(
      user: current_user,
      prompt: prompt,
      ip_address: request.remote_ip,
      current_session: session
    ).call

    if result.success?
      @show_recipe = result.recipe if result.recipe
      redirect_to result.recipe ? search_path(result.recipe) : new_search_path
    else
      @user = current_user || User.new
      flash.now[:error] = result.error_message
      render :new, status: result.status
    end
  end

  def saved
    @q = current_user.search_recipes.ransack(params[:q])
    @saved_recipes = @q.result(distinct: true).order(created_at: :desc)
    @liked_recipes = current_user.liked_search_recipes.ransack(params[:q]).result(distinct: true).order(created_at: :desc)
    @user_liked_ids = current_user.likes.pluck(:search_recipe_id).to_set
    # @saved_recipes = current_user.search_recipes.order(created_at: :desc)
  end

  def favorites
    @q = current_user.liked_search_recipes.ransack(params[:q])
    @liked_recipes = @q.result(distinct: true).order(created_at: :desc)
    @user_liked_ids = current_user.likes.pluck(:search_recipe_id).to_set
  end

  def destroy
    # Rails.logger.debug("SearchRecipe.count: #{SearchRecipe.count}")
    begin
      @show_recipe.destroy!
      flash[:success] = "削除成功!"
      redirect_to saved_searches_path
      # Rails.logger.debug("SearchRecipe.count: #{SearchRecipe.count}")
    rescue ActiveRecord::RecordNotDestroyed => e
      Rails.logger.error("レシピ削除失敗: #{e.message}")
      @q = current_user.search_recipes.ransack(params[:q])
      @saved_recipes = @q.result(distinct: true).order(created_at: :desc)
      @liked_recipes = current_user.liked_search_recipes.ransack(params[:q]).result(distinct: true).order(created_at: :desc)
      flash.now[:error] = "削除に失敗しました"
      render :saved, status: :unprocessable_entity
    end
  end

  def optimized
    permitted = optimized_params
    result = OptimizedRecipeCreationService.new(
      user: current_user,
      params: optimized_params,
      ip_address: request.remote_ip,
      current_session: session
    ).call

    if result.success?
      @show_recipe = result.recipe if result.recipe
      redirect_to result.recipe ? search_path(result.recipe) : new_search_path
    else
      @user = current_user || User.new
      flash.now[:error] = result.error_message
      render :new, status: result.status
    end
  end

  private

  def search_count
    real_ip = request.env["HTTP_X_FORWARDED_FOR"]&.split(",")&.first || request.remote_ip

    if current_user
      search_count = SearchLog.where(user_id: current_user.id, search_time: Date.current.all_day).count
      @search_limit = 5 - search_count
    else
      guest_last_search = cookies[:guest_searched_at]
      if guest_last_search.present? && Time.parse(guest_last_search).to_date == Date.today
        @search_limit = 0
      else
        search_count = SearchLog.where(ip_address: real_ip, search_time: Date.current.all_day).count
        @search_limit = 1 - search_count
      end
    end
  end

  def check_search_limit
    if @search_limit <= 0
      flash[:alert] = "1日に検索できる回数を超えました。"
      redirect_to user_signed_in? ? saved_searches_path : root_path
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

  def optimized_params
    params.permit(
      :target_p, :target_f, :target_c
    )
  end

  def set_show
    @show_recipe = current_user.search_recipes.find_by(id: params[:id])
    unless @show_recipe
      redirect_to saved_searches_path, alert: "不正な操作です" and return
    end
  end
end
