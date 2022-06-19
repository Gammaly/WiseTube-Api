# frozen_string_literal: true

require_relative './app'

module WiseTube
  # Web controller for WiseTube API
  class Api < Roda
    route('captions') do |routing|
      # routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @link_route = "#{@api_root}/captions"

      # GET api/v1/captions?q=keyword
      routing.on do
        q = routing.params['q']
        routing.get do
          data = GetCaptions.call(q:)
          
          { data: }.to_json
        rescue GetCaptions::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetCaptions::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.warn "Search Error: #{e.inspect}"
          routing.halt 500, { message: "API server error #{e.inspect}" }.to_json
        end
      end
    end
  end
end
