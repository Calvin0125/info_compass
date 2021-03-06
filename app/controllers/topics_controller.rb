class TopicsController < ApplicationController
  before_action :require_login

  def research_index 
    render :research_index
    if !helpers.current_user.visited_research_topics
      helpers.current_user.update(visited_research_topics: true)
    end
  end

  def news_index
    render :news_index
    if !helpers.current_user.visited_news_topics
      helpers.current_user.update(visited_news_topics: true)
    end
  end

  def create
    title = params[:topic][:title]
    category = params[:topic][:category]
    topic = Topic.new(title: title, category: category, user: helpers.current_user)
    if topic.save
      params[:topic][:search_terms].each do |term|
        if term.length > 0
          SearchTerm.create(term: term, topic: topic)
        end
      end
      error = topic.reload.add_new_articles
      flash[:danger] = error if error != ''
    else
      flash[:danger] = topic.errors.full_messages.join(" ")
    end

    if category == "research"
      redirect_to research_path
    elsif category == "news"
      redirect_to news_path
    end
  end
  
  def destroy
    topic = Topic.find(params[:id])
    if topic.user == helpers.current_user
      topic.destroy
    end

    if topic.category == "research"
      redirect_to research_path
    elsif topic.category == "news"
      redirect_to news_path
    end
  end
end
