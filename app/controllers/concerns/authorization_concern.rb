module AuthorizationConcern
  extend ActiveSupport::Concern

  included do
    before_action :authorize!
    rescue_from AuthorizationError, with: :render_authorization_error
  end

  def authorize!
    provided_token = request.authorization&.gsub(/Bearer\s/, '')
    access_token = AccessToken.find_by_token(provided_token)
    @current_user = access_token&.user
    raise AuthorizationError unless @current_user
  end

  def render_authorization_error
    error = {
        status: 403,
        source: {pointer: "/headers/authorization"},
        title: "You are not authorized",
        detail: "You have no right to access to this resource"
    }
    render json: {errors: [error]}, status: :forbidden
  end
end