# frozen_string_literal: true

require 'json'
require 'sequel'

module WiseTube
  # Holds a full secret link
  class Link < Sequel::Model
    many_to_one :playlist

    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :title, :description, :url, :image

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def image
      SecureDB.decrypt(image_secure)
    end

    def image=(plaintext)
      self.image_secure = SecureDB.encrypt(plaintext)
    end

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
