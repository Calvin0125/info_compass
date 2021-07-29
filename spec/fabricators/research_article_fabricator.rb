require 'faker'

Fabricator(:research_article) do
  id { 1 }
  title { Faker::Lorem.words(number: 5).join(" ") }
  author_csv { [Faker::Name.name, Faker::Name.name, Faker::Name.name].join(",") }
  summary { Faker::Lorem.words(number: 25).join(" ") }
  api { "arxiv" }
  api_id { "http://arxiv.org/abs/hep-ex/0307015" }
  article_published { "2021-05-31" }
  article_updated { "2021-06-04" }
  research_topic_id { 1 }
  status { "new" }
end
