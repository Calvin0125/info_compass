require 'faker'

Fabricator(:research_topic) do
  title { Faker::Lorem.words(number: 2).join(" ") }
end
