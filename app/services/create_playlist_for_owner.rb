# frozen_string_literal: true

module WiseTube
  # Service object to create a new playlist for an owner
  class CreatePlaylistForOwner
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create playlists'
      end
    end

    def self.call(auth:, playlist_data:)
      raise ForbiddenError unless auth[:scope].can_write?('playlists')

      auth[:account].add_owned_playlist(playlist_data)
    end
  end
end
