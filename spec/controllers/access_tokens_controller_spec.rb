require 'rails_helper'

RSpec.describe AccessTokensController, type: :controller do
  describe "#create" do
    shared_examples_for "invalid_code" do
      let(:error) do
        {
            "status" => 401,
            "source" => {"pointer" => "/code"},
            "title"  => "Code Invalid or Missing",
            "detail" => "You must provide a valid code in order to exchange"
        }
      end

      it "should return 401 response" do
        subject
        expect(response).to have_http_status :unauthorized
      end

      it "should render proper error" do
        subject
        expect(json_errors.length).to eq 1
        expect(json_errors).to include error
      end
    end

    context "when no code in params" do
      subject { post :create }
      it_behaves_like "invalid_code"
    end

    context "when code is invalid" do
      let(:sawyer_error) { double("Sawyer::Resource", error: "bad_verification_code") }
      before do
        allow_any_instance_of(Octokit::Client)
            .to receive(:exchange_code_for_token).and_return(sawyer_error)
      end
      subject { post :create, params: {'code' => 'invalid_code'} }
      it_behaves_like "invalid_code"
    end

    context "when code is valid" do
      subject { post :create, params: {'code' => 'valid_code'} }
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

      it "creates a new User object" do
        expect { subject }.to change { User.count }.by 1
      end

      it "render a 200 OK status code" do
        subject
        expect(response).to have_http_status :ok
      end

      it "renders a valid json of access_token" do
        subject
        access_token = User.find_by_login('jsmith1').access_token.token
        expect(json_data['attributes']).to eq( {'token' => access_token} )
      end
    end
  end

  describe "#destroy" do
    subject { delete :destroy }

    context "when request is valid" do
      it "should return proper status code" do
        subject
        expect(response).to have_http_status :forbidden
      end
    end

    context "when request is invalid" do

    end
  end
end