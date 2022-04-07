# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/link'

module WiseTube
  # Web controller for WiseTube API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Link.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'WiseTubeAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'links' do
            # GET api/v1/links/[id]
            routing.get String do |id|
              response.status = 200
              Link.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Link not found' }.to_json
            end

            # GET api/v1/links
            routing.get do
              response.status = 200
              output = { link_ids: Link.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/links
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_link = Link.new(new_data)

              if new_link.save
                response.status = 201
                { message: 'Link saved', id: new_doc.id }.to_json
              else
                routing.halt 400, { message: 'Could not save link' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
