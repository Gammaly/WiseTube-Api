# frozen_string_literal: true

module WiseTube
  # Add a collaborator to another owner's existing playlist
  class AddCollaboratorToPlaylist
    # Error for owner cannot be collaborator
    class OwnerNotCollaboratorError < StandardError
      def message = 'Owner cannot be collaborator of playlist'
    end

    def self.call(email:, playlist_id:)
      collaborator = Account.first(email:)
      playlist = Playlist.first(id: playlist_id)
      raise(OwnerNotCollaboratorError) if playlist.owner_id == collaborator.id

      playlist.add_collaborator(collaborator)
    end
  end
end
