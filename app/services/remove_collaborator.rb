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

    def self.call(req_username:, collab_email:, playlist_id:)
      account = Account.first(username: req_username)
      playlist = Playlist.first(id: playlist_id)
      collaborator = Account.first(email: collab_email)

      policy = CollaborationRequestPolicy.new(playlist, account, collaborator)
      raise ForbiddenError unless policy.can_remove?

      playlist.remove_collaborator(collaborator)
      collaborator
    end
  end
end
