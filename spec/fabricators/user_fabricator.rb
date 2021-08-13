require 'faker'

Fabricator(:user) do
  username { Faker::Name.unique.first_name }
  email { Faker::Internet.email }
  password { "password" }
  visited_research_topics { false }
  token { nil }
end
