# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Link Handling' do
  before do
    wipe_database

    DATA[:playlists].each do |playlist_data|
      WiseTube::Playlist.create(playlist_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    link_data = DATA[:links][1]
    playlist = WiseTube::Playlist.first
    new_link = playlist.add_link(link_data)

    link = WiseTube::Link.find(id: new_link.id)
    _(link.title).must_equal link_data['title']
    _(link.url).must_equal link_data['url']
    _(link.description).must_equal link_data['description']
    _(link.image).must_equal link_data['image']
  end

  it 'SECURITY: should not use deterministic integers' do
    link_data = DATA[:links][1]
    playlist = WiseTube::Playlist.first
    new_link = playlist.add_link(link_data)

    _(new_link.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    link_data = DATA[:links][1]
    playlist = WiseTube::Playlist.first
    new_link = playlist.add_link(link_data)
    stored_link = app.DB[:links].first

    _(stored_link[:description_secure]).wont_equal new_link.description
    _(stored_link[:image_secure]).wont_equal new_link.image
  end
end