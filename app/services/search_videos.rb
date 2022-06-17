# frozen_string_literal: true

module WiseTube
  # Search videos
  class SearchVideos
    # Error for cannot search video
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that link'
      end
    end

    # Error for cannot find a video
    class NotFoundError < StandardError
      def message
        'We could not find that link'
      end
    end

    # Search Video
    def self.call(q:)
      raise NotFoundError unless q

      data = Youtube::YoutubeApi.new.search_videos(q)
      # raise ForbiddenError unless policy.can_view?

      data
    end
  end
end
