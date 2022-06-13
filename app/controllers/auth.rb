# frozen_string_literal: true

require 'roda'
require_relative './app'

module WiseTube
  # Web controller for WiseTube API
  class Api < Roda
    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      # YES_SignedRequest
      # # All requests in this route require signed requests
      # begin
      #   @request_data = SignedRequest.new(Api.config).parse(request.body.read)
      # rescue SignedRequest::VerificationError
      #   routing.halt '403', { message: 'Must sign request' }.to_json
      # end

      routing.on 'register' do
        # POST api/v1/auth/register
        routing.post do
          # YES_SignedRequest
          # VerifyRegistration.new(@request_data).call

          # NO_SignedRequest
          reg_data = JsonRequestBody.parse_symbolize(request.body.read)
          VerifyRegistration.new(reg_data).call
          # END

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
          # YES_SignedRequest
          # auth_account = AuthenticateAccount.call(@request_data)

          # NO_SignedRequest
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          auth_account = AuthenticateAccount.call(credentials)
          # END

          { data: auth_account }.to_json
        rescue AuthenticateAccount::UnauthorizedError => e
          puts [e.class, e.message].join ': '
          Api.logger.error 'Could not authenticate credentials'
          routing.halt '401', { message: 'Invalid credentials' }.to_json
        end
      end

      # POST /api/v1/auth/gh_sso
      routing.post 'gh_sso' do
        # YES_SignedRequest
        # auth_account = AuthorizeGithubSso.new.call(@request_data[:access_token])

        # NO_SignedRequest
        auth_request = JsonRequestBody.parse_symbolize(request.body.read)
        auth_account = AuthorizeSso.new.call(auth_request[:access_token])
        # END

        { data: auth_account }.to_json
      rescue StandardError => e
        puts "FAILED to validate Github account: #{e.inspect}"
        puts e.backtrace
        routing.halt 400
      end

      # POST /api/v1/auth/google_sso
      routing.post 'google_sso' do
        # YES_SignedRequest
        # auth_account = AuthorizeGoogleSso.new.call(@request_data[:access_token])

        # NO_SignedRequest
        auth_request = JsonRequestBody.parse_symbolize(request.body.read)
        auth_account = AuthorizeSso.new.call(auth_request[:access_token])
        # END

        { data: auth_account }.to_json
      rescue StandardError => e
        puts "FAILED to validate Google account: #{e.inspect}"
        puts e.backtrace
        routing.halt 400
      end
    end
  end
end
