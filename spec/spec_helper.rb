# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:links].delete
  app.DB[:playlists].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:links] = YAML.safe_load File.read('app/db/seeds/link_seeds.yml')
DATA[:playlists] = YAML.safe_load File.read('app/db/seeds/playlist_seeds.yml')