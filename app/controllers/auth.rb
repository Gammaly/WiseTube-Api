# frozen_string_literal: true

require 'roda'
require_relative './app'

module WiseTube
  # Web controller for WiseTube API
  class Api < Roda
    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      routing.on 'register' do
        # POST api/v1/auth/register
        routing.post do
          reg_data = JsonRequestBody.parse_symbolize(request.body.read)
          VerifyRegistration.new(reg_data).call

          response.status = 202
          { message: 'Verification email sent' }.to_json
        rescue VerifyRegistration::InvalidRegistration => e
          routing.halt 400, { message: e.message }.to_json
        rescue VerifyRegistration::EmailProviderError
          routing.halt 500, { message: 'Error sending email' }.to_json
        rescue StandardError => e
          Api.logger.error "Could not verify registration: #{e.inspect}"
          routing.halt 500
        end
      end

      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          auth_account = AuthenticateAccount.call(credentials)
          { data: auth_account }.to_json
        rescue AuthenticateAccount::UnauthorizedError => e
          puts [e.class, e.message].join ': '
          Api.logger.error 'Could not authenticate credentials'
          routing.halt '401', { message: 'Invalid credentials' }.to_json
        end
      end

      # POST /api/v1/auth/gh_sso
      routing.post 'gh_sso' do
        auth_request = JsonRequestBody.parse_symbolize(request.body.read)
        puts auth_request
        auth_account = AuthorizeGithubSso.new.call(auth_request[:access_token])
        
        { data: auth_account }.to_json
      rescue StandardError => error
        puts "FAILED to validate Github account: #{error.inspect}"
        puts error.backtrace
        routing.halt 400
      end

      # POST /api/v1/auth/google_sso
      routing.post 'google_sso' do
        auth_request = JsonRequestBody.parse_symbolize(request.body.read)
        puts auth_request
        auth_account = AuthorizeGoogleSso.new.call(auth_request[:access_token])
        
        { data: auth_account }.to_json
      rescue StandardError => error
        puts "FAILED to validate Google account: #{error.inspect}"
        puts error.backtrace
        routing.halt 400
      end

    end
    # rubocop:enable Metrics/BlockLength
  end
end
