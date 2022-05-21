# frozen_string_literal: true

module WiseTube
  # Policy to determine if an account can view a particular playlist
  class CollaborationRequestPolicy
    def initialize(playlist, requestor_account, target_account)
      @playlist = playlist
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = PlaylistPolicy.new(requestor_account, playlist)
      @target = PlaylistPolicy.new(target_account, playlist)
    end

    def can_invite?
      @requestor.can_add_collaborators? && @target.can_collaborate?
    end

    def can_remove?
      @requestor.can_remove_collaborators? && target_is_collaborator?
    end

    private

    def target_is_collaborator?
      @playlist.collaborators.include?(@target_account)
    end
  end
end
