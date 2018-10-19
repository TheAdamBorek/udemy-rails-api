require 'rails_helper'

shared_examples_for "forbidden_request" do
  let(:authorization_error) do
    {
        "status" => 403,
        "source" => {"pointer" => "/headers/authorization"},
        "title"  => "You are not authorized",
        "detail" => "You have no right to access to this resource"
    }
  end

  it "should return proper status code" do
    subject
    expect(response).to have_http_status :forbidden
  end

  it "should return proper json error" do
    subject
    expect(json_errors).to include authorization_error
  end
end

shared_examples_for "resource_with_restricted_access" do
  context "when request doesn't have token" do
    it_behaves_like 'forbidden_request'
  end

  context "when request has invalid token" do
    before { request.headers['Authorization'] = 'Invalid token' }
    it_behaves_like 'forbidden_request'
  end
end