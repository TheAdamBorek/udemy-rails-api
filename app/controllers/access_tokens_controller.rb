class AccessTokensController < ApplicationController
  rescue_from AuthenticateGithubUserUseCase::AuthenticationError, with: :wrong_github_code_error
  rescue_from ActionController::ParameterMissing, with: :wrong_github_code_error

  def create
    access_token = use_case.authenticate_user code_params
    render json: access_token
  end

  private

  def wrong_github_code_error
    error = {
        "status" => 401,
        "source" => {"pointer" => "/code"},
        "title"  => "Code Invalid or Missing",
        "detail" => "You must provide a valid code in order to exchange"
    }
    render json: {"errors" => [error]}, status: :unauthorized
  end

  def use_case
    @use_case ||= AuthenticateGithubUserUseCase.new
  end

  def code_params
    params.require('code')
  end
end
