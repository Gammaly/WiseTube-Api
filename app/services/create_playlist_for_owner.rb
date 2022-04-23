# frozen_string_literal: true

module WiseTube
  # Service object to create a new playlist for an owner
  class CreatePlaylistForOwner
    def self.call(owner_id:, playlist_data:)
      Account.find(id: owner_id)
             .add_owned_playlist(playlist_data)
    end
  end
end
