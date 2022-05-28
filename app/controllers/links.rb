# frozen_string_literal: true

require_relative './app'

module WiseTube
  # Web controller for WiseTube API
  class Api < Roda
    route('links') do |routing|
      routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @link_route = "#{@api_root}/links"

      # GET api/v1/links/[link_id]
      routing.on String do |link_id|
        @req_link = Link.first(id: link_id)

        routing.get do
          link = GetLinkQuery.call(
            auth: @auth, document: @req_document
          )

          { data: link }.to_json
        rescue GetLinkQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetLinkQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.warn "Link Error: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
