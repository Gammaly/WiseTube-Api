# frozen_string_literal: true

module WiseTube
  # Policy to determine if an account can view a particular playlist
  class PlaylistPolicy
    def initialize(account, playlist, auth_scope = nil)
      @account = account
      @playlist = playlist
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_is_owner? || account_is_collaborator?)
    end

    # duplication is ok!
    def can_edit?
      can_read? && (account_is_owner? || account_is_collaborator?)
    end

    def can_delete?
      can_read? && account_is_owner?
    end

    def can_leave?
      account_is_collaborator?
    end

    def can_add_links?
      can_read? && (account_is_owner? || account_is_collaborator?)
    end

    def can_remove_links?
      can_read? && (account_is_owner? || account_is_collaborator?)
    end

    def can_add_collaborators?
      can_read? && account_is_owner?
    end

    def can_remove_collaborators?
      can_read? && account_is_owner?
    end

    def can_collaborate?
      !(account_is_owner? or account_is_collaborator?)
    end

    # rubocop:disable Metrics/MethodLength
    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_links: can_add_links?,
        can_delete_links: can_remove_links?,
        can_add_collaborators: can_add_collaborators?,
        can_remove_collaborators: can_remove_collaborators?,
        can_collaborate: can_collaborate?
      }
    end
    # rubocop:enable Metrics/MethodLength

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('projects') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('projects') : false
    end

    def account_is_owner?
      @playlist.owner == @account
    end

    def account_is_collaborator?
      @playlist.collaborators.include?(@account)
    end
  end
end
