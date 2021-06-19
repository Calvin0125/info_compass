# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
calvin = User.create(username: "Calvin123", email: "calvin@conley.com", password: "password")
ai = ResearchTopic.create(title: "Artificial Intelligence", user_id: calvin.id)
SearchTerm.create(research_topic_id: ai.id, term: "artificial intelligence")
SearchTerm.create(research_topic_id: ai.id, term: "machine learning")

synthetic_biology = ResearchTopic.create(title: "Synthetic Biology", user_id: calvin.id)
SearchTerm.create(research_topic_id: synthetic_biology.id, term: "synthetic biology")

jellyfish = ResearchTopic.create(title: "Immortal Jellyfish", user_id: calvin.id)
SearchTerm.create(research_topic_id: jellyfish.id, term: "immortal jellyfish")
SearchTerm.create(research_topic_id: jellyfish.id, term: "turritopsis dohrnii")

ResearchTopic.add_new_articles

ai.research_articles.order(id: :asc).limit(3).each { |article| article.update(status: "read") }
ai.research_articles.order(id: :desc).limit(3).each { |article| article.update(status: "saved") }

synthetic_biology.research_articles.order(id: :asc).limit(3).each { |article| article.update(status: "read") }
synthetic_biology.research_articles.order(id: :desc).limit(3).each { |article| article.update(status: "saved") }

ResearchTopic.add_new_articles
