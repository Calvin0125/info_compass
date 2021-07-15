require 'rails_helper.rb'

describe PagesController do
  context "user logged in" do
    it_behaves_like "a page that requires no login" do
      let(:action) { get :index }
    end
  end

  context "no user logged in" do
    it "renders the index page" do
      get :index
      expect(response).to render_template :index
    end
  end
end
