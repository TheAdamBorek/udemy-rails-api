

class AuthenticateGithubUserUseCase
  class AuthenticationError < StandardError; end

  attr_reader :user, :access_token

  def authenticate_user(code)
    raise AuthenticationError if code.blank?
    github_token = github_token_for code
    user_data    = fetch_user_data_for github_token
    prepare_user_for user_data
    prepare_access_token
  end

  private
  def github_token_for(code)
    client_id     = ENV['GITHUB_CLIENT_ID']
    client_secret = ENV['GITHUB_CLIENT_SECRET']
    client        = Octokit::Client.new(
        client_id:     client_id,
        client_secret: client_secret
    )
    github_token  = client.exchange_code_for_token code
    if github_token.try(:error).present?
      raise AuthenticationError
    end
    github_token
  end

  def fetch_user_data_for(access_token)
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

  def prepare_access_token
    @access_token = if @user.access_token.present?
      user.access_token
    else
      user.create_access_token
    end
  end

end