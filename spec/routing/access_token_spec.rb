require 'rails_helper'

describe 'access token routing' do
  it "should route to create on post" do
    expect(post 'login').to route_to 'access_tokens#create'
  end
end