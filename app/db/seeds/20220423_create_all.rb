# frozen_string_literal: true

require './app/controllers/helpers'
include WiseΤube::SecureRequestHelpers

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, playlists, links'
    create_accounts
    create_owned_playlists
    create_links
    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_playlists.yml")
PLAYLIST_INFO = YAML.load_file("#{DIR}/playlists_seed.yml")
LINK_INFO = YAML.load_file("#{DIR}/links_seed.yml")
CONTRIB_INFO = YAML.load_file("#{DIR}/playlists_collaborators.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    WiseTube::Account.create(account_info)
  end
end

def create_owned_playlists
  OWNER_INFO.each do |owner|
    account = WiseTube::Account.first(username: owner['username'])
    owner['playlist_name'].each do |playlist_name|
      playlist_data = PLAYLIST_INFO.find { |playlist| playlist['name'] == playlist_name }
      account.add_owned_playlist(playlist_data)
    end
  end
end

def create_links
  link_info_each = LINK_INFO.each
  playlists_cycle = WiseTube::Playlist.all.cycle
  loop do
    link_info = link_info_each.next
    playlist = playlists_cycle.next

    auth_token = AuthToken.create(playlist.owner)
    auth = scoped_auth(auth_token)

    WiseTube::CreateLink.call(
      auth: auth, playlist:, link_data: link_info
    )
  end
end

def add_collaborators
  contrib_info = CONTRIB_INFO
  contrib_info.each do |contrib|
    playlist = WiseΤube::Playlist.first(name: contrib['playlist_name'])

    auth_token = AuthToken.create(playlist.owner)
    auth = scoped_auth(auth_token)

    contrib['collaborator_email'].each do |email|
      WiseTube::AddCollaborator.call(
        auth: auth, playlist: playlist, collab_email: email
      )
    end
  end
end
