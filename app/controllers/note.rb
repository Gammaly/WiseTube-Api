# frozen_string_literal: true

require_relative './app'
require 'pp'

module WiseTube
  # Web controller for WiseTube API
  class Api < Roda
    route('note') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @playlist_route = "#{@api_root}/note"
      routing.on String do |link_id|
        @req_link = Link.first(id: link_id)

        # POST api/v1/note/[ID]
        routing.post do
          req_body = JSON.parse(routing.body.read)
          puts "note: #{req_body}"
          note = AddNote.call(
            auth: @auth,
            req_link: @req_link,
            note: req_body['note']
          )
          puts "#{{ data: note }.to_json}"
          { data: note }.to_json
        rescue GetLinkQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetLinkQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND LINK ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
