require 'faker'

Fabricator(:research_topic) do
  id { 1 }
  title { Faker::Lorem.words(number: 2).join(" ") }
  user_id { 1 }
end
