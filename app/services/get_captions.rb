# frozen_string_literal: true

module WiseTube
  # Search videos
  class GetCaptions
    # Error for cannot search video
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that caption'
      end
    end

    # Error for cannot find a video
    class NotFoundError < StandardError
      def message
        'We could not find that caption'
      end
    end

    # Get caption
    def self.call(input)
      raise NotFoundError unless input

      Python::Command.new.captions(input).call
      # raise ForbiddenError unless policy.can_view?
    end
  end
end
