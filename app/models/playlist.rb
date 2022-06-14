# frozen_string_literal: true

require 'json'
require 'sequel'

module WiseTube
  # Models a playlist
  class Playlist < Sequel::Model
    many_to_one :owner, class: :'WiseTube::Account'

    many_to_many :collaborators,
                 class: :'WiseTube::Account',
                 join_table: :accounts_playlists,
                 left_key: :playlist_id, right_key: :collaborator_id

    one_to_many :links

    plugin :association_dependencies,
           links: :destroy,
           collaborators: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :playlist_url

    def to_h
      {
        type: 'playlist',
        attributes: {
          id:,
          name:,
          playlist_url:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          collaborators:,
          links:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end

    def public_attributes_hash
      {
        id:       id,
        name:     name,
        repo_url: repo_url
      }
    end

    def relationships_hash
      {
        owner:         owner,
        collaborators: collaborators,
        documents:     documents
      }
    end
  end
end
