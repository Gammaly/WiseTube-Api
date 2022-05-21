# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaborator service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      WiseTube::Account.create(account_data)
    end

    playlist_data = DATA[:playlists].first

    @owner = WiseTube::Account.all[0]
    @collaborator = WiseTube::Account.all[1]
    @playlist = WiseTube::CreatePlaylistForOwner.call(
      owner_id: @owner.id, playlist_data:
    )
  end

  it 'HAPPY: should be able to add a collaborator to a playlist' do
    WiseTube::AddCollaborator.call(
      account: @owner,
      project: @project,
      collab_email: @collaborator.email
    )

    _(@collaborator.playlists.count).must_equal 1
    _(@collaborator.playlists.first).must_equal @playlist
  end

  it 'BAD: should not add owner as a collaborator' do
    _(proc {
      WiseTube::AddCollaborator.call(
        account: @owner,
        project: @project,
        collab_email: @owner.email
      )
    }).must_raise WiseTube::AddCollaborator::ForbiddenError
  end
end
