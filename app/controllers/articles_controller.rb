class ArticlesController < ApplicationController

  before_action :require_login

  def create
    topic = Topic.find(params[:topic_id])
    user = helpers.current_user
    if topic.user != user
      flash[:danger] = "You can only request articles for topics that belong to you."
    elsif user.todays_news_query_count >= 25
      flash[:danger] = "You can only request new news articles 25 times per day."
    else
      topic.add_new_articles
      user.add_news_query
    end

    redirect_to news_path
  end

  def update
    article = Article.find(params[:id])
    if article.topic.user == helpers.current_user
      article.update(article_params)
    else
      flash[:danger] = "You can only edit articles that belong to you."
    end

    redirect_to research_path
  end

  private

  def article_params
    params.require(:article).permit(:notes, :status)
  end
end
