require 'faker'

Fabricator(:user) do
  username { Faker::Name.unique.first_name }
  email { Faker::Internet.email }
  password { "password" }
end
