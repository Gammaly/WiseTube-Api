# frozen_string_literal: true

require 'http'

module WiseTube
  # Find or create an SsoAccount based on Github code
  class AuthorizeGoogleSso
    def call(access_token)
      google_account = get_google_account(access_token)
      sso_account = find_or_create_sso_account(google_account)

      account_and_token(sso_account)
    end

    def get_google_account(access_token)
      google_response = HTTP.headers(
        user_agent: 'WiseTube',
        authorization: "token #{access_token}", # Not neccessary for google
        accept: 'application/json'
      ).get("#{ENV.fetch('GOOGLE_ACCOUNT_URL')}?access_token=#{access_token}")
      puts google_response
      raise unless google_response.status == 200

      account = GoogleAccount.new(JSON.parse(google_response))
      { username: account.username, email: account.email }
    end

    def find_or_create_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        Account.create_github_account(account_data)
    end

    def account_and_token(account)
      {
        type: 'sso_account',
        attributes: {
          account:,
          auth_token: AuthToken.create(account)
        }
      }
    end
  end
end
