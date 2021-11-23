# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
calvin = User.create(username: "Calvin123", email: "calvin@conley.com", password: "password")
ai = Topic.create(title: "Artificial Intelligence", category: "research", user_id: calvin.id)
SearchTerm.create(topic_id: ai.id, term: "artificial intelligence")
SearchTerm.create(topic_id: ai.id, term: "machine learning")

synthetic_biology = Topic.create(title: "Synthetic Biology", category: "research", user_id: calvin.id)
SearchTerm.create(topic_id: synthetic_biology.id, term: "synthetic biology")

jellyfish = Topic.create(title: "Immortal Jellyfish", category: "research", user_id: calvin.id)
SearchTerm.create(topic_id: jellyfish.id, term: "immortal jellyfish")
SearchTerm.create(topic_id: jellyfish.id, term: "turritopsis dohrnii")

Topic.add_new_articles

ai.articles.order(id: :asc).limit(3).each { |article| article.update(status: "read") }
ai.articles.order(id: :desc).limit(3).each { |article| article.update(status: "saved") }

synthetic_biology.articles.order(id: :asc).limit(3).each { |article| article.update(status: "read") }
synthetic_biology.articles.order(id: :desc).limit(3).each { |article| article.update(status: "saved") }

Topic.add_new_articles
