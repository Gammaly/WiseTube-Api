# frozen_string_literal: true

module WiseTube
  module Python
    # Basic gateway to git shell commands
    class Command
      PYTHON = 'python3'

      def initialize
        @command = []
        @params = []
      end

      def captions(video_id)
        @command = 'captions.py'
        @params = video_id
        self
      end

      def word_frequency(video_id)
        @command = 'word_frequency.py'
        @params = video_id
        self
      end

      def full_command
        [PYTHON, @command, @params]
          .compact
          .flatten
          .join(' ')
      end

      def call
        `#{full_command}`
      end
    end
  end
end
