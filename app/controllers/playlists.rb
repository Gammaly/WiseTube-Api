# frozen_string_literal: true

require_relative './app'
require 'pp'

# rubocop:disable Metrics/BlockLength
module WiseTube
  # Web controller for WiseTube API
  class Api < Roda
    route('playlists') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @playlist_route = "#{@api_root}/playlists"
      routing.on String do |playlist_id|
        @req_playlist = Playlist.first(id: playlist_id)

        # GET api/v1/playlists/[ID]
        routing.get do
          playlist = GetPlaylistQuery.call(auth: @auth, playlist: @req_playlist)
          { data: playlist }.to_json
        rescue GetPlaylistQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetPlaylistQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND PROJECT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.on('links') do
          # POST api/v1/playlists/[playlist_id]/links
          puts JSON.parse(routing.body.read)
          puts @req_playlist
          puts @auth[:account] # @auth

          routing.post do
            new_link = CreateLink.call(
              auth: @auth,
              playlist: @req_playlist,
              link_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@link_route}/#{new_link.id}"
            mess = { message: 'Link saved', data: new_link }.to_json
            puts mess
            { message: 'Link saved', data: new_link }.to_json
          rescue CreateLink::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateLink::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.warn "Could not create link: #{e.message}"
            puts "Could not create link: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('collaborators') do
          # PUT api/v1/playlists/[playlist_id]/collaborators
          routing.put do
            req_data = JSON.parse(routing.body.read)

            collaborator = AddCollaborator.call(
              auth: @auth,
              playlist: @req_playlist,
              collab_email: req_data['email']
            )

            { data: collaborator }.to_json
          rescue AddCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/playlists/[playlist_id]/collaborators
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            collaborator = RemoveCollaborator.call(
              auth: @auth,
              collab_email: req_data['email'],
              playlist_id:
            )

            { message: "#{collaborator.username} removed from playlistet",
              data: collaborator }.to_json
          rescue RemoveCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing.is do
        # GET api/v1/playlists
        routing.get do
          playlists = PlaylistPolicy::AccountScope.new(@auth_account).viewable

          JSON.pretty_generate(data: playlists)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any playlists' }.to_json
        end

        # POST api/v1/playlists
        routing.post do
          new_data = JSON.parse(routing.body.read)

          new_playlist = CreatePlaylistForOwner.call(
            auth: @auth, playlist_data: new_data
          )

          response.status = 201
          response['Location'] = "#{@playlist_route}/#{new_playlist.id}"
          { message: 'Playlist saved', data: new_playlist }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue CreatePlaylistForOwner::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.error "Unknown error: #{e.message}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
