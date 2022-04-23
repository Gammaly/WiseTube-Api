# frozen_string_literal: true

module WiseTube
  # Create new configuration for a playlist
  class CreateLinkForPlaylist
    def self.call(playlist_id:, link_data:)
      Playlist.first(id: playlist_id)
              .add_link(link_data)
    end
  end
end
