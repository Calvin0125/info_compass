require 'faker'

Fabricator(:user) do
  username { Faker::Name.unique.first_name }
  email { Faker::Internet.email }
  time_zone { "Eastern Time (US & Canada)" }
  password { "password" }
  visited_research_topics { false }
  token { nil }
end
