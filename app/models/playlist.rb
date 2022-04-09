# frozen_string_literal: true

require 'json'
require 'sequel'

module WiseTube
  # Models a playlist
  class Playlist < Sequel::Model
    one_to_many :links
    plugin :association_dependencies, links: :destroy

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'playlist',
            attributes: {
              id:,
              name:,
              playlist_url:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
