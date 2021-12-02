class ArticlesController < ApplicationController
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
