# frozen_string_literal: true

require_relative './app'

module WiseTube
  # Web controller for WiseTube API
  class Api < Roda
    route('search') do |routing|
      #routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @link_route = "#{@api_root}/search"

      # GET api/v1/search?q=keyword
      routing.on do
        q = routing.params["q"]
        routing.get do
          data = SearchVideos.call(q: q)

          { data: data }.to_json
        rescue SearchVideos::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue SearchVideos::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.warn "Search Error: #{e.inspect}"
          routing.halt 500, { message: "API server error #{e.inspect}" }.to_json
        end
      end
    end
  end
end
