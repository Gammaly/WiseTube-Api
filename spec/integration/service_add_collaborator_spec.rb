# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaborator service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      WiseTube::Account.create(account_data)
    end

    playlist_data = DATA[:playlists].first

    @owner_data = DATA[:accounts][0]
    @owner = WiseTube::Account.all[0]
    @collaborator = WiseTube::Account.all[1]
    @playlist = @owner.add_owned_playlist(playlist_data)
  end

  it 'HAPPY: should be able to add a collaborator to a playlist' do
    auth = authorization(@owner_data)

    WiseTube::AddCollaborator.call(
      auth: auth,
      playlist: @playlist,
      collab_email: @collaborator.email
    )

    _(@collaborator.playlists.count).must_equal 1
    _(@collaborator.playlists.first).must_equal @playlist
  end

  it 'BAD: should not add owner as a collaborator' do
    auth = WiseTube::AuthenticateAccount.call(
      username: @owner_data['username'],
      password: @owner_data['password']
    )

    _(proc {
      WiseTube::AddCollaborator.call(
        auth: auth,
        playlist: @playlist,
        collab_email: @owner.email
      )
    }).must_raise WiseTube::AddCollaborator::ForbiddenError
  end
end
