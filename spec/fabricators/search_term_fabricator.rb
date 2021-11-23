require 'faker'

Fabricator(:search_term) do
  id { 1 }
  term { Faker::Lorem.words(number: 2).join(" ") }
  topic_id { 1 }
end
