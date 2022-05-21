# frozen_string_literal: true

module WiseTube
  # Add a collaborator to another owner's existing playlist
  class GetPlaylistQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that playlist'
      end
    end

    # Error for cannot find a playlist
    class NotFoundError < StandardError
      def message
        'We could not find that playlist'
      end
    end

    def self.call(account:, playlist:)
      raise NotFoundError unless playlist

      policy = PlaylistPolicy.new(account, playlist)
      raise ForbiddenError unless policy.can_view?

      playlist.full_details.merge(policies: policy.summary)
    end
  end
end
