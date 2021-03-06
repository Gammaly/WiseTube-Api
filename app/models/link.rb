# frozen_string_literal: true

require 'json'
require 'sequel'

module WiseTube
  # Holds a full secret link
  class Link < Sequel::Model
    many_to_one :playlist

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true

    plugin :whitelist_security
    set_allowed_columns :title, :description, :url, :image, :note, :comment

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

    def note
      SecureDB.decrypt(note_secure)
    end

    def note=(plaintext)
      self.note_secure = SecureDB.encrypt(plaintext)
    end

    def comment
      SecureDB.decrypt(comment_secure)
    end

    def comment=(plaintext)
      self.comment_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'link',
          attributes: {
            id:,
            title:,
            description:,
            url:,
            image:,
            note:,
            comment:
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
