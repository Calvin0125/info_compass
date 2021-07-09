class SearchTermsController < ApplicationController
  def destroy
    term = SearchTerm.find(params[:id])
    topic = term.research_topic
    if topic.user == helpers.current_user
      term.destroy
      topic.refresh_new_articles
    else
      flash[:danger] = "You can only delete search terms for topics that belong to you."
    end
    redirect_to research_topics_path
  end
end
