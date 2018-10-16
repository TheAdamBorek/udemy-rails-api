class AuthenticationError < StandardError; end

class AuthenticateGithubUserUseCase
  attr_reader :user

  def authenticate_user(code)
    access_token = fetch_access_token code
    user_data = fetch_user_data access_token
    prepare_user_for user_data
    @access_token = if @user.access_token.present?
      user.access_token
    else
      user.create_access_token
    end
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
    client_id = ENV['GITHUB_CLIENT_ID']
    client_secret = ENV['GITHUB_CLIENT_SECRET']
    client = Octokit::Client.new(
        client_id:     client_id,
        client_secret: client_secret
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

  def prepare_user_for(user_data)
    @user = if User.exists?(login: user_data[:login])
      User.find_by_login(user_data[:login])
    else
      User.create user_data
    end
  end
end