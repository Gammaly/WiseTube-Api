# frozen_string_literal: true

require 'roda'
require_relative './app'

module WiseTube
  # Web controller for WiseTube API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('playlists') do |routing|
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

            new_link = CreateLinkForPlaylist.call(
              playlist_id:, link_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@link_route}/#{new_link.id}"
            { message: 'Link saved', data: new_link }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.warn "MASS-ASSIGNMENT: #{e.message}"
            routing.halt 500, { message: 'Error creating link' }.to_json
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

      # GET api/v1/playlists/
      routing.get do
        account = Account.first(username: @auth_account['username'])
        projects = account.projects
        JSON.pretty_generate(data: projects)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any playlists' }.to_json
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
    # rubocop:enable Metrics/BlockLength
  end
end
