# frozen_string_literal: true

module WiseTube
  # Add a collaborator to another owner's existing playlist
  class AddCollaborator
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as collaborator'
      end
    end

    def self.call(account:, playlist:, collab_email:)
      invitee = Account.first(email: collab_email)
      policy = CollaborationRequestPolicy.new(playlist, account, invitee)
      raise ForbiddenError unless policy.can_invite?

      playlist.add_collaborator(invitee)
      invitee
    end
  end
end
