class AccessTokensController < ApplicationController
  rescue_from AuthenticateGithubUserUseCase::AuthenticationError, with: :render_github_code_error
  rescue_from ActionController::ParameterMissing, with: :render_github_code_error

  skip_before_action :authorize!, only: [:create]

  def create
    access_token = use_case.authenticate_user code_params
    render json: access_token
  end

  def destroy
    @current_user.access_token.destroy
    render status: :no_content
  end

  private

  def use_case
    @use_case ||= AuthenticateGithubUserUseCase.new
  end

  def code_params
    params.require('code')
  end

  def render_github_code_error
    error = {
        status: 401,
        source: {pointer: "/code"},
        title:  "Code Invalid or Missing",
        detail: "You must provide a valid code in order to exchange"
    }
    render json: {errors: [error]}, status: :unauthorized
  end


end
