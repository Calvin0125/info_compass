feature "User" do
  background do
    @user = Fabricate(:user, password: "password")
  end

  def login
    visit '/login'
    fill_in "Username", with: @user.username
    fill_in "Password", with: "password"
    click_button "Login"
  end

  scenario "user logs in" do
    login
    expect(page).to have_content "You have been logged in."
  end

  scenario "user logs out" do
    login
    click_button "navbarToggler"
    sleep 1
    click_link "accountDropdownLink"
    click_link "Sign Out"
  end

  scenario "create new user" do
    visit "/new_user"
    fill_in "Email", with: "user@internet.com"
    fill_in "Username", with: "User123"
    fill_in "Password", with: "password"
    click_button "Create Account"
    expect(page).to have_content("Your account has been created, please log in.")
  end
end
