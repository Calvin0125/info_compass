class SearchTermsController < ApplicationController
  def create
    term = SearchTerm.new(search_term_params)
    topic = term.topic
    if topic.user == helpers.current_user
      if term.save
        topic.reload.refresh_new_articles
      else
        flash[:danger] = term.errors.full_messages.join(" ")
      end
    else
      flash[:danger] = "You can only add search terms to topics that belong to you."
    end

    redirect_to research_path
  end

  def destroy
    term = SearchTerm.find(params[:id])
    topic = term.topic
    if topic.user == helpers.current_user
      term.destroy
      topic.refresh_new_articles
    else
      flash[:danger] = "You can only delete search terms for topics that belong to you."
    end
    redirect_to research_path
  end

  private

  def search_term_params
    params.require(:search_term).permit(:term, :topic_id)
  end
end
