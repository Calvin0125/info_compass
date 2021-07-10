class SearchTermsController < ApplicationController
  def create
    term = SearchTerm.new(search_term_params)
    topic = term.research_topic
    if topic.user == helpers.current_user
      term.save
      topic.refresh_new_articles
    else
      flash[:danger] = "You can only add search terms to topics that belong to you."
    end

    redirect_to research_topics_path
  end

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

  private

  def search_term_params
    params.require(:search_term).permit(:term, :research_topic_id)
  end
end
