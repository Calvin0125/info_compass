class ResearchTopicsController < ApplicationController
  before_action :require_login

  def index
  end

  def create
    title = params[:research_topic][:title]
    topic = ResearchTopic.create(title: title, user: helpers.current_user)
    params[:research_topic][:search_terms].each do |term|
      if term.length > 0
        SearchTerm.create(term: term, research_topic: topic)
      end
    end
    topic.add_new_articles
    redirect_to research_topics_path
  end
end
