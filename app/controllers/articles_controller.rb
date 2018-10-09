class ArticlesController < ApplicationController
  def index
    render json: 'hello'
  end

  def show
    render json: params[:id]
  end
end