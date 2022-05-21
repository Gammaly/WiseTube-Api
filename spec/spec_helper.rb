# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  WiseTube::Link.map(&:destroy)
  WiseTube::Playlist.map(&:destroy)
  WiseTube::Account.map(&:destroy)
end

def auth_header(account_data)
  auth = WiseTube::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {
  accounts: YAML.load(File.read('app/db/seeds/accounts_seed.yml')),
  links: YAML.load(File.read('app/db/seeds/links_seed.yml')),
  playlists: YAML.load(File.read('app/db/seeds/playlists_seed.yml'))
}.freeze
