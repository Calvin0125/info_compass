def login(user = Fabricate(:user))
  session[:user_id] = user.id
end

def current_user
  User.find(session[:user_id]) if session[:user_id]
end

def fabricate_research_article(id, status = "new")
  user = Fabricate(:user, id: id)
  topic = Fabricate(:topic, id: id, user_id: id)
  article = Fabricate(:article, id: id, topic_id: id, status: status)
end
