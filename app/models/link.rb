# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module WiseTube
  STORE_DIR = 'app/db/store'

  # Holds a full secret link
  class Link
    # Create a new link by passing in hash of attributes
    def initialize(new_link)
      @id          = new_link['id'] || new_id
      @title       = new_link['title']
      @description = new_link['description']
      @url         = new_link['url']
      @image       = new_link['image']
    end

    attr_reader :id, :title, :description, :url, :image

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          type: 'link',
          id:,
          title:,
          description:,
          url:,
          image:
        },
        options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(WiseTube::STORE_DIR) unless Dir.exist? WiseTube::STORE_DIR
    end

    # Stores link in file store
    def save
      File.write("#{WiseTube::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one link
    def self.find(find_id)
      link_file = File.read("#{WiseTube::STORE_DIR}/#{find_id}.txt")
      Link.new JSON.parse(link_file)
    end

    # Query method to retrieve index of all links
    def self.all
      Dir.glob("#{WiseTube::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(WiseTube::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
