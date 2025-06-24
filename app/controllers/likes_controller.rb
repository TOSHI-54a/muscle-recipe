class LikesController < ApplicationController
  before_action :set_search_recipe
  def create
    current_user.likes.create(search_recipe: @search_recipe)
    respond_to do |format|
      format.turbo_stream { render "likes/create", formats: [ :turbo_stream ] } # Turbo用
      format.html { redirect_to search_recipes_path(@search_recipe) } # JS無効ブラウザ用
    end
  end

  def destroy
    @like = current_user.likes.find_by(search_recipe: @search_recipe)
    @like.destroy if @like

    respond_to do |format|
      format.turbo_stream { render format: :turbo_stream }
      format.html { redirect_to search_recipes_path(@search_recipe), notice: "解除しました" }
    end
  end

  private

  def set_search_recipe
    @search_recipe = SearchRecipe.find(params[:search_recipe_id])
  end
end
