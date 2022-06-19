# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaboratorToPlaylist service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      WiseTube::Account.create(account_data)
    end
  end

  it 'HAPPY: should authenticate valid account credentials' do
    credentials = DATA[:accounts].first
    account = WiseTube::AuthenticateAccount.call(
      username: credentials['username'], password: credentials['password']
    )
    _(account).wont_be_nil
  end

  it 'SAD Authentication: will not authenticate with invalid password' do
    credentials = DATA[:accounts].first
    _(proc {
      WiseTube::AuthenticateAccount.call(
        username: credentials['username'], password: 'malword'
      )
    }).must_raise WiseTube::AuthenticateAccount::UnauthorizedError
  end

  it 'BAD Authentication: will not authenticate with invalid credentials' do
    _(proc {
      WiseTube::AuthenticateAccount.call(
        username: 'maluser', password: 'malword'
      )
    }).must_raise WiseTube::AuthenticateAccount::UnauthorizedError
  end
end
