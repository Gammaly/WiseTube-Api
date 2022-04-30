# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module WiseTube
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_playlists, class: :'WiseTube::Playlist', key: :owner_id
    many_to_many :collaborations,
                 class: :'WiseTube::Playlist',
                 join_table: :accounts_playlists,
                 left_key: :collaborator_id, right_key: :playlist_id

    plugin :association_dependencies,
           owned_playlists: :destroy,
           collaborations: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def playlists
      owned_playlists + collaborations
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = WiseTube::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            username:,
            email:
          }
        }, options
      )
    end
  end
end
