# frozen_string_literal: true

require 'roda'
require 'json'

module WiseTube
  # Web controller for WiseTube API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'WiseTubeAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'playlists' do
          @playlist_route = "#{@api_root}/playlists"

          routing.on String do |playlist_id|
            routing.on 'links' do
              @link_route = "#{@api_root}/playlists/#{playlist_id}/links"
              # GET api/v1/playlists/[playlist_id]/links/[link_id]
              routing.get String do |link_id|
                link = Link.where(playlist_id:, id: link_id).first
                link ? link.to_json : raise('Link not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/playlists/[playlists_id]/links
              routing.get do
                output = { data: Playlist.first(id: playlist_id).links }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find links'
              end

              # POST api/v1/playlists/[ID]/links
              routing.post do
                new_data = JSON.parse(routing.body.read)
                playlist = Playlist.first(id: playlist_id)
                new_link = playlist.add_link(new_data)

                if new_link
                  response.status = 201
                  response['Location'] = "#{@link_route}/#{new_link.id}"
                  { message: 'Link saved', data: new_link }.to_json
                else
                  routing.halt 400, 'Could not save link'
                end

              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/playlists/[ID]
            routing.get do
              playlist = Playlist.first(id: playlist_id)
              playlist ? playlist.to_json : raise('Playlist not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/playlists
          routing.get do
            output = { data: Playlist.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find playlists' }.to_json
          end

          # POST api/v1/playlists
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_playlist = Playlist.new(new_data)
            raise('Could not save playlist') unless new_playlist.save

            response.status = 201
            response['Location'] = "#{@playlist_route}/#{new_playlist.id}"
            { message: 'Playlist saved', data: new_playlist }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
