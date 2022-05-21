# frozen_string_literal: true

module WiseTube
  # Add a collaborator to another owner's existing playlist
  class GetLinkQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that link'
      end
    end

    # Error for cannot find a playlist
    class NotFoundError < StandardError
      def message
        'We could not find that link'
      end
    end

    # Link for given requestor account
    def self.call(requestor:, link:)
      raise NotFoundError unless link

      policy = LinkPolicy.new(requestor, link)
      raise ForbiddenError unless policy.can_view?

      link
    end
  end
end
