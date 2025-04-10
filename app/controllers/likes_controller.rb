class LikesController < ApplicationController
  def create
    @search_recipe = SearchRecipe.find(params[:search_recipe_id])
    current_user.likes.create(search_recipe: @search_recipe)
    redirect_to search_path(@search_recipe)
  end

  def destroy
    @search_recipe = SearchRecipe.find(params[:search_recipe_id])
    like = current_user.likes.find_by(search_recipe: @search_recipe)
    like.destroy if like
    redirect_to search_path(@search_recipe)
  end
end
