# frozen_string_literal: true

module WiseTube
  # Add a collaborator to another owner's existing playlist
  class RemoveCollaborator
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(auth:, collab_email:, playlist_id:)
      playlist = Playlist.first(id: playlist_id)
      collaborator = Account.first(email: collab_email)

      policy = CollaborationRequestPolicy.new(
        playlist, auth[:account], collaborator, auth[:scope]
      )
      raise ForbiddenError unless policy.can_remove?

      playlist.remove_collaborator(collaborator)
      collaborator
    end
  end
end
