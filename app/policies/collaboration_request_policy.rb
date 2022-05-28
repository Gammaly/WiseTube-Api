# frozen_string_literal: true

module WiseTube
  # Policy to determine if an account can view a particular playlist
  class CollaborationRequestPolicy
    def initialize(playlist, requestor_account, target_account, auth_scope = nil)
      @playlist = playlist
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = PlaylistPolicy.new(requestor_account, playlist, auth_scope)
      @target = PlaylistPolicy.new(target_account, playlist, auth_scope)
    end

    def can_invite?
      can_write? &&
        @requestor.can_add_collaborators? && @target.can_collaborate?
    end

    def can_remove?
      can_write? &&
        @requestor.can_remove_collaborators? && target_is_collaborator?
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('projects') : false
    end

    def target_is_collaborator?
      @playlist.collaborators.include?(@target_account)
    end
  end
end
