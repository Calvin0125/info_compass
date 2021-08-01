class ResearchTopicsController < ApplicationController
  before_action :require_login

  def index
    render :index
    if !helpers.current_user.visited_research_topics
      helpers.current_user.update(visited_research_topics: true)
    end
  end

  def create
    title = params[:research_topic][:title]
    topic = ResearchTopic.new(title: title, user: helpers.current_user)
    if topic.save
      params[:research_topic][:search_terms].each do |term|
        if term.length > 0
          SearchTerm.create(term: term, research_topic: topic)
        end
      end
      topic.add_new_articles
    else
      flash[:danger] = topic.errors.full_messages.join(" ")
    end
    redirect_to research_topics_path
  end
  
  def destroy
    topic = ResearchTopic.find(params[:id])
    if topic.user == helpers.current_user
      topic.destroy
    end

    redirect_to research_topics_path
  end
end
