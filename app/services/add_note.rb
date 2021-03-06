# frozen_string_literal: true

module WiseTube
  # Add a collaborator to another owner's existing playlist
  class AddNote
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add a note'
      end
    end

    def self.call(auth:, req_link:, note:)
      policy = LinkPolicy.new(auth[:account], req_link, auth[:scope])
      raise ForbiddenError unless policy.can_edit?

      req_link.note = note
      req_link.save
    end
  end
end
