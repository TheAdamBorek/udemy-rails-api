require 'rails_helper'

describe AuthenticateGithubUserUseCase do
  describe 'exchange_token' do
    let(:useCase) { described_class.new }
    subject { useCase.authenticate_user 'dummy_code' }

    context 'when token is incorrect' do
     let(:error) do
        double("Sawyer::Resource", error: "bad_verification_code")
     end

      before do
        allow_any_instance_of(Octokit::Client)
            .to receive(:exchange_code_for_token).and_return(error)
      end

      it 'should raise an error' do
        expect { useCase.authenticate_user 'failing_token' }
            .to raise_error AuthenticationError
      end
    end

    context 'when token is correct' do
      let(:user_data) do
        {
            login: 'jsmith1',
            url: 'http://fakeimg.pl/200x200',
            avatar_url: 'http://fakeimg.pl/200x200',
            name: 'John Smith'
        }
      end
      before do
        allow_any_instance_of(Octokit::Client)
          .to receive(:exchange_code_for_token).and_return('valid_access_token')
        allow_any_instance_of(Octokit::Client)
          .to receive(:user).and_return(user_data)
      end
      it 'should save the user when it does not exists' do
        expect{ subject }.to change { User.count }.by 1
        expect(User.last.name).to eq 'John Smith'
      end
    end
  end
end