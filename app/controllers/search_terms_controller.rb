class SearchTermsController < ApplicationController
  def destroy
    term = SearchTerm.find(params[:id])
    if term.research_topic.user == helpers.current_user
      term.destroy
    else
      flash[:danger] = "You can only delete search terms for topics that belong to you."
    end

    redirect_to research_topics_path
  end
end
