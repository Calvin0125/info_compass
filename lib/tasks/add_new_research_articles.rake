desc "Query arXiv API and add new research articles to database"
task add_new_research_articles: :environment do
  ResearchTopic.add_new_articles
end
