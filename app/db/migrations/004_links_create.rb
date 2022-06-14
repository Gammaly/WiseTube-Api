# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:links) do
      uuid :id, primary_key: true
      foreign_key :playlist_id, table: :playlists

      String :title, null: false
      # String :relative_path, null: false, default: ''
      String :description_secure
      String :url, null: false, default: ''
      String :image_secure

      String :note_secure
      String :comment_secure

      DateTime :created_at
      DateTime :updated_at

      unique [:playlist_id, :url, :title]
    end
  end
end
