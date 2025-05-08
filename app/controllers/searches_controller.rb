require "net/http"
require "json"

class SearchesController < ApplicationController
  before_action :search_count, only: %i[ new create ]
  before_action :check_search_limit, only: :create
  before_action :set_show, only: %i[show destroy]
  skip_before_action :authenticate_user!, only: %i[ new create show ]

  def new
    @search_recipes = SearchRecipe.new
    @user = current_user || (flash[:alert] = "⚠️注意：ゲストの検索回数は1日1回です！")
    if session[:guest_recipe]
      @guest_recipe = OpenStruct.new(
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

        # Rails.logger.debug "保存後のSearchRecipe: #{@show_recipe.inspect}"
        # Rails.logger.debug "保存後のresponse_data: #{@show_recipe.response_data.inspect}"

        # @recommendation = recipe_response
        redirect_to search_path(@show_recipe)
      else
        SearchLog.create!(ip_address: request.remote_ip, search_time: Time.current)
        session[:guest_recipe] = recipe_response
        flash.now[:notice] = "レシピは保存されません。"
        redirect_to new_search_path
      end
    else
      Rails.logger.debug("ChatGPT APIからのレスポンスが無効: #{recipe_response.inspect}")
      flash.now[:error] = "レシピの取得に失敗しました。もう一度お試しください。"
      render :new, status: :unprocessable_entity
    end

  rescue => e
    # Rails.logger.debug "Recipe response is empty or invalid: #{@recommendations.inspect}"
    Rails.logger.debug "Error in create action: #{e.message}"
    flash[:error] = "レシピの取得に失敗しました: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def saved
    @q = current_user.search_recipes.ransack(params[:q])
    @saved_recipes = @q.result(distinct: true).order(created_at: :desc)
    # @saved_recipes = current_user.search_recipes.order(created_at: :desc)
  end

  def destroy
    if @show_recipe.destroy!
      flash[:success] = "削除成功!"
      redirect_to saved_searches_path
    else
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
      @search_limit = 50 - search_count
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
    @show_recipe = SearchRecipe.find(params[:id])
  end

  def safe_float(value)
    Float(value)
  rescue ArgumentError, TypeError
    nil
  end
end
