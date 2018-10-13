class AuthenticationError < StandardError; end

class AuthenticateGithubUserUseCase
  def authenticate_user(code)
    access_token = fetch_access_token code
    user_data = fetch_user_data access_token
    User.create! user_data
  end

  private
  def fetch_access_token(code)
    access_token = exchange_github_code_for_token code
    if access_token.try(:error).present?
      raise AuthenticationError
    end
    access_token
  end

  def exchange_github_code_for_token(code)
    client = Octokit::Client.new(
        client_id:     ENV['GITHUB_CLIENT_ID'],
        client_secret: ENV['GITHUB_CLIENT_SECRET']
    )
    client.exchange_code_for_token code
  end

  def fetch_user_data(access_token)
    client = Octokit::Client.new(
        access_token: access_token
    )
    client.user.to_h
        .slice(:login, :avatar_url, :url, :name)
        .merge(provider: 'github')
  end
end