class ResearchArticlesController < ApplicationController
  def update
    article = ResearchArticle.find(params[:id])
    if article.research_topic.user == helpers.current_user
      article.update(article_params)
    else
      flash[:danger] = "You can only edit articles that belong to you."
    end

    redirect_to research_topics_path
  end

  private

  def article_params
    params.require(:research_article).permit(:notes, :status)
  end
end
