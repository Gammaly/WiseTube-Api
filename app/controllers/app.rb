# frozen_string_literal: true

require 'roda'
require 'json'

module WiseTube
  # Web controller for WiseTube API
  class Api < Roda
    plugin :halt

    # rubocop:disable Metrics/BlockLength
    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'WiseTubeAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(username: username)
              account ? account.to_json : raise('Account not found')
            rescue StandardError
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            raise('Could not save account') unless new_account.save

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Playlist saved', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            puts e.inspect
            routing.halt 500, { message: error.message }.to_json
          end
        end

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

              # POST api/v1/playlists/[playlist_id]/links
              routing.post do
                new_data = JSON.parse(routing.body.read)
                playlist = Playlist.first(id: playlist_id)
                new_link = playlist.add_link(new_data)
                raise 'Could not save link' unless new_link

                response.status = 201
                response['Location'] = "#{@link_route}/#{new_link.id}"
                { message: 'Link saved', data: new_link }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
              end
            end

            # GET api/v1/playlists/[playlist_id]
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
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'Unknown server error' }.to_json
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
