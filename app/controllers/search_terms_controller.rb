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

    if topic.category == "research"
      redirect_to research_path
    elsif topic.category == "news"
      redirect_to news_path
    end
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

    if topic.category == "research"
      redirect_to research_path
    elsif topic.category == "news"
      redirect_to news_path
    end
  end

  private

  def search_term_params
    params.require(:search_term).permit(:term, :topic_id)
  end
end
