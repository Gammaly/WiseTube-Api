# frozen_string_literal: true

module WiseTube
  # Service object to create a new playlist for an owner
  class CreatePlaylistForOwner
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more documents'
      end
    end

    def self.call(auth:, project_data:)
      raise ForbiddenError unless auth[:scope].can_write?('projects')

      auth[:account].add_owned_project(project_data)
    end
  end
end
