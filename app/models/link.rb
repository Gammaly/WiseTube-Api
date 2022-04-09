# frozen_string_literal: true

require 'json'
require 'sequel'

module WiseTube
  # Holds a full secret link
  class Link < Sequel::Model
    many_to_one :playlist

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'link',
            attributes: {
              id:,
              title:,
              description:,
              url:,
              image:
            }
          },
          included: {
            playlist:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
