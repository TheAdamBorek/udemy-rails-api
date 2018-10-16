require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  describe '#validations' do
    it 'should have working factory bot' do
      expect(build :access_token).to be_valid
    end

    it "should validate the token" do
      access_token = create :access_token
      expect(build :access_token, token: nil).to be_invalid
      expect(build :access_token, token: access_token.token).to be_invalid
    end
  end

  describe '#new' do
    it 'should have a token after init' do
      expect(AccessToken.new.token).to be_present
    end

    it 'should have unique token' do
      user = create :user
      expect{ user.create_access_token }.to change{ AccessToken.count }.by(1)
      expect(user.build_access_token).to be_valid
    end

    it 'should generate token once' do
      user = create :user
      access_token = user.create_access_token
      expect(access_token.token).to eq(access_token.reload.token)
    end
  end
end
