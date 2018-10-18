require 'rails_helper'

describe AuthenticateGithubUserUseCase do
  describe 'authenticate_user' do
    let(:use_case) { described_class.new }

    shared_examples_for 'wrong_code' do
      context 'when code is incorrect' do
        let(:sawyer_error) do
          double("Sawyer::Resource", error: "bad_verification_code")
        end

        before do
          allow_any_instance_of(Octokit::Client)
              .to receive(:exchange_code_for_token).and_return(sawyer_error)
        end

        it 'should raise an error' do
          expect { subject }
              .to raise_error AuthenticateGithubUserUseCase::AuthenticationError
        end
      end
    end

    context 'when code is incorrect' do
      subject { use_case.authenticate_user 'invalid_code' }
      it_behaves_like 'wrong_code'
    end

    context 'when code is empty' do
      subject { use_case.authenticate_user nil }
      it_behaves_like 'wrong_code'
    end

    context 'when code is correct' do
      subject { use_case.authenticate_user 'valid_code' }
      let(:user_data) do
        {
            login:      'jsmith1',
            url:        'http://fakeimg.pl/200x200',
            avatar_url: 'http://fakeimg.pl/200x200',
            name:       'John Smith'
        }
      end

      before do
        allow_any_instance_of(Octokit::Client)
            .to receive(:exchange_code_for_token).and_return('valid_access_token')
        allow_any_instance_of(Octokit::Client)
            .to receive(:user).and_return(user_data)
      end

      it 'should save the user when it does not exists' do
        expect { subject }.to change { User.count }.by 1
        expect(User.last.name).to eq 'John Smith'
        expect(use_case.user.id).to eq User.last.id
      end

      it 'should fetch user if it exists already' do
        user = User.create!(user_data.merge(provider: 'github'))
        expect { subject }.to_not change { User.count }
        expect(use_case.user.id).to eq user.id
      end

      it 'should creates and sets user access token' do
        expect { subject }.to change { AccessToken.count }.by 1
        expect(use_case.access_token).to be_present
      end
    end
  end
end