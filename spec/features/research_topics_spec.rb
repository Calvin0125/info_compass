feature "Research Topics" do
   background do
    @user = Fabricate(:user, password: "password")
  end

  def login
    visit '/login'
    fill_in "Username", with: @user.username
    fill_in "Password", with: "password"
    click_button "Login"
  end
end
