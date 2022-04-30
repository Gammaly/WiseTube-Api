# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Playlist Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting projects' do
    it 'HAPPY: should be able to get list of all playlists' do
      WiseTube::Playlist.create(DATA[:playlists][0]).save
      WiseTube::Playlist.create(DATA[:playlists][1]).save

      get 'api/v1/playlists'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single playlist' do
      existing_playlist = DATA[:playlists][1]
      WiseTube::Playlist.create(existing_playlist).save
      id = WiseTube::Playlist.first.id

      get "/api/v1/playlists/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['attributes']['id']).must_equal id
      _(result['attributes']['name']).must_equal existing_playlist['name']
    end

    it 'SAD: should return error if unknown playlist requested' do
      get '/api/v1/playlists/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      WiseTube::Playlist.create(name: 'New Playlist')
      WiseTube::Playlist.create(name: 'Newer Playlist')
      get 'api/v1/playlists/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Playlists' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @playlist_data = DATA[:playlists][1]
    end

    it 'HAPPY: should be able to create new playlists' do
      existing_playlist = DATA[:playlists][1]

      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/playlists', existing_playlist.to_json, req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      playlist = WiseTube::Playlist.first

      _(created['id']).must_equal playlist.id
      _(created['name']).must_equal existing_playlist['name']
      _(created['playlist_url']).must_equal existing_playlist['playlist_url']
    end

    it 'SECURITY: should not create playlist with mass assignment' do
      bad_data = @playlist_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/playlists', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
