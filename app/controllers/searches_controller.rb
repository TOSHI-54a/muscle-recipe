require "net/http"
require "json"

class SearchesController < ApplicationController
  before_action :search_count, only: %i[ new create ]
  before_action :check_search_limit, only: :create
  before_action :set_show, only: %i[show destroy]
  skip_before_action :authenticate_user!, only: %i[ new create show ]

  def new
    @search_recipes = SearchRecipe.new
    if current_user
      @user = current_user
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
    # @saved_recipes = current_user.search_recipes.order(created_at: :desc)
  end

  def favorites
    @q = current_user.liked_search_recipes.ransack(params[:q])
    @liked_recipes = @q.result(distinct: true).order(created_at: :desc)
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
    uri = URI(ENV.fetch("FASTAPI_URL", "http://fastapi:8000/suggest_recipe"))
    req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    req.body = {
      target_p: safe_float(params[:target_p]),
      target_f: safe_float(params[:target_f]),
      target_c: safe_float(params[:target_c]),
      body_info: safe_float(params[:body_info])
    }.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") { |http| http.request(req) }
    @recipe = JSON.parse(res.body)
    # binding.pry

    # FastAPIの出力をプロンプトに変換
    prompt = FastapiPromptBuilder.build(@recipe)
    # binding.pry

    # ChatGPTからレシピを取得
    recipe_response = ChatGptService.new.fetch_pfc_prompt(prompt)

    # 保存 or 表示用データにセット
    if current_user
      @show_recipe = SearchRecipe.create!(
        user: current_user,
        query: prompt,
        search_time: Time.current,
        response_data: recipe_response
      )
      flash[:success] = "レシピの取得に成功しました"
      redirect_to search_path(@show_recipe)
    else
      session[:guest_recipe] = recipe_response
      redirect_to new_search_path
    end

  rescue => e
    logger.error("FastAPI connection failed: #{e.message}")
    render plain: "FastAPI通信エラー", status: 500
  end


  private

  def search_count
    real_ip = request.env["HTTP_X_FORWARDED_FOR"]&.split(",")&.first || request.remote_ip

    if current_user
      search_count = SearchLog.where(user_id: current_user.id, search_time: Date.current.all_day).count
      @search_limit = 10 - search_count
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

  def set_show
    @show_recipe = current_user.search_recipes.find_by(id: params[:id])
    unless @show_recipe
      redirect_to saved_searches_path, alert: "不正な操作です" and return
    end
  end

  def safe_float(value)
    Float(value)
  rescue ArgumentError, TypeError
    nil
  end
end
