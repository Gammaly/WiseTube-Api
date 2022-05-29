# frozen_string_literal: true

module WiseTube
  # Maps Google account details to attributes
  class GoogleAccount
    def initialize(google_account)
      @google_account = google_account
    end

    def username
      @google_account['name'] + "(#{@google_account['email']})" + '@google'
    end

    def email
      @google_account['email']
    end
  end
end
