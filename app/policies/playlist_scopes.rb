# frozen_string_literal: true

module WiseTube
  # Policy to determine if account can view a playlist
  class PlaylistPolicy
    # Scope of playlist policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_playlists(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |playlist|
            includes_collaborator?(playlist, @current_account)
          end
        end
      end

      private

      def all_playlists(account)
        account.owned_playlists + account.collaborations
      end

      def includes_collaborator?(playlist, account)
        playlist.collaborators.include? account
      end
    end
  end
end
