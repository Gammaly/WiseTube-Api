# frozen_string_literal: true

module WiseTube
  # Add a collaborator to another owner's existing playlist
  class CreateLink
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more links'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a link with those attributes'
      end
    end

    def self.call(account:, playlist:, link_data:)
      policy = PlaylistPolicy.new(account, playlist)
      raise ForbiddenError unless policy.can_add_links?

      add_link(playlist, link_data)
    end

    def self.add_link(playlist, link_data)
      playlist.add_link(link_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
