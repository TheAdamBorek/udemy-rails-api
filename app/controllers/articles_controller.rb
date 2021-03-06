class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: [:index, :show]

  def index
    articles = Article.recent.page(params[:page]).per(params[:per_page])
    render json: articles
  end

  def show
    article = Article.find_by_id(params[:id])
    render json: article
  end

  def create
    article = Article.new(article_params)
    article.save!
    render json: article, status: :created
  rescue
    render json:       article,
           adapter:    :json_api,
           serializer: ErrorSerializer,
           status:     :unprocessable_entity
  end

  def update

  end

  private

  def article_params
    params.require(:data)
        .require(:attributes)
        .permit(:title, :content)
  end
end