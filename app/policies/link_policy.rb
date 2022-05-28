# frozen_string_literal: true

# Policy to determine if account can view a playlist
class LinkPolicy
  def initialize(account, link, auth_scope = nil)
    @account = account
    @link = link
    @auth_scope = auth_scope
  end

  def can_view?
    can_read? && (account_owns_playlist? || account_collaborates_on_playlist?)
  end

  def can_edit?
    can_read? && (account_owns_playlist? || account_collaborates_on_playlist?)
  end

  def can_delete?
    can_read? && (account_owns_playlist? || account_collaborates_on_playlist?)
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def can_read?
    @auth_scope ? @auth_scope.can_read?('documents') : false
  end

  def can_write?
    @auth_scope ? @auth_scope.can_write?('documents') : false
  end

  def account_owns_playlist?
    @link.playlist.owner == @account
  end

  def account_collaborates_on_playlist?
    @link.playlist.collaborators.include?(@account)
  end
end
