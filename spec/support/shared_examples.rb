require 'rails_helper.rb'

shared_examples "a page that requires login" do
  it "redirects to login" do
    action
    expect(response).to redirect_to login_path
  end

  it "sets the flash notice" do
    action
    expect(flash[:danger]).to eq("You must be logged in to do that.")
  end
end

shared_examples "a page that requires no login" do
  it "redirects to my account" do
    login
    action
    expect(response).to redirect_to my_account_path
  end

  it "sets the flash notice" do
    login
    action
    expect(flash[:warning]).to eq("You are already logged in.")
  end
end
