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
    def self.call(input:)
      raise NotFoundError unless input

      Youtube::YoutubeApi.new.search_videos(input)
      # raise ForbiddenError unless policy.can_view?
    end
  end
end
