# frozen_string_literal: true

require 'google/apis/youtube_v3'
require 'pp'

YOUTUBE_API_KEY = ENV.fetch('YOUTUBE_API_KEY').to_s.freeze

module WiseTube
  module Youtube
    # Get data from Youtube Api
    class YoutubeApi
      def initialize
        @service = Google::Apis::YoutubeV3::YouTubeService.new
        @service.key = YOUTUBE_API_KEY.to_s
      end

      def search_videos(keyword)
        get_videos_items('snippet', **{ q: keyword.to_s, type: 'video' })
      end

      def get_videos_items(part, **params)
        response = @service.list_searches(part, **params).to_json
        JSON.parse(response).fetch('items')
      end
    end
  end
end
