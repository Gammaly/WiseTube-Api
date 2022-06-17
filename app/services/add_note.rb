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

    def self.call(req_link:, note:)
      # link = Link.first(link_id: link_id)
      req_link.note = note
      req_link.save
    end
  end
end
