# frozen_string_literal: true

# Policy to determine if account can view a playlist
class LinkPolicy
  def initialize(account, link)
    @account = account
    @link = link
  end

  def can_view?
    account_owns_playlist? || account_collaborates_on_playlist?
  end

  def can_edit?
    account_owns_playlist? || account_collaborates_on_playlist?
  end

  def can_delete?
    account_owns_playlist? || account_collaborates_on_playlist?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def account_owns_playlist?
    @link.playlist.owner == @account
  end

  def account_collaborates_on_playlist?
    @link.playlist.collaborators.include?(@account)
  end
end
