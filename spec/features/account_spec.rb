feature "Account" do
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
    click_link "Sign Out"
  end

  scenario "create new user" do
    visit "/new_account"
    fill_in "Email", with: "user@internet.com"
    fill_in "Username", with: "User123"
    fill_in "Password", with: "password"
    click_button "Create Account"
    expect(page).to have_content("Your account has been created, please log in.")
  end

  scenario "user edits details" do
    login
    click_link "accountDropdownLink"
    click_link "My Account"
    click_link "Edit Details"
    fill_in "Username", with: ""
    fill_in "Username", with: "User123"
    fill_in "Email", with: ""
    fill_in "Email", with: "user123@email.com"
    fill_in "Current Password", with: "password"
    click_button "Update"
    expect(page).to have_content("Username: User123")
    expect(page).to have_content("Email: user123@email.com")
  end
end
