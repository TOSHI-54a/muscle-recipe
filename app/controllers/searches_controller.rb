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
      flash[:alert] = "⚠️注意：ゲストの検索回数は1日1回です！"
      @user = User.new
    end
    # ゲストレシピ表示用
    if session[:guest_recipe]
      @guest_recipe = Struct.new(
        id: nil,
        user_id: nil,
        query: session[:guest_recipe][:query],
        search_time: Time.current,
        response_data: session[:guest_recipe]
      )
    end
    session.delete(:guest_recipe)
  end

  def show; end

  def index; end

  def create
    if current_user.nil? && session[:guest_searched]
      flash[:alert] = "ゲストの検索回数は1日1回です。"
      redirect_to new_user_path and return
    end
    prompt = recipe_params.to_json
    recipe_response = ChatGptService.new.fetch_recipe(prompt)
    if recipe_response.present?
      if current_user
        SearchLog.create!(user_id: current_user.id, search_time: Time.current)
        @show_recipe = SearchRecipe.create!(
          user: current_user,
          query: prompt,
          search_time: Time.current,
          response_data: recipe_response
        )
        redirect_to search_path(@show_recipe)
      else
        SearchLog.create!(ip_address: request.remote_ip, search_time: Time.current)
        session[:guest_recipe] = recipe_response
        flash.now[:notice] = "レシピは保存されません。"
        redirect_to new_search_path
      end
    else
      Rails.logger.debug("ChatGPT APIからのレスポンスが無効: #{recipe_response.inspect}")
      @user = current_user || User.new
      flash.now[:error] = "レシピの取得に失敗しました。もう一度お試しください"
      render :new, status: :unprocessable_entity
    end

  rescue Net::OpenTimeout, SocketError => e
    Rails.logger.error("外部接続エラー: #{e.message}")
    @user = current_user || User.new
    flash[:error] = "外部APIに接続できませんでした。時間をおいて再試行してください。"
    render :new, status: :service_unavailable

  rescue StandardError => e
    Rails.logger.error("不明なエラー: #{e.message}")
    @user = current_user || User.new
    flash[:error] = "予期しないエラーが発生しました。もう一度お試しください。"
    render :new, status: :unprocessable_entity
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
      search_count = SearchLog.where(ip_address: real_ip, search_time: Date.current.all_day).count
      @search_limit = 1 - search_count
    end
  end

  def check_search_limit
    if @search_limit <= 0
      flash[:alert] = "1日に検索できる回数を超えました。"
      redirect_to saved_searches_path
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
