# frozen_string_literal: true

require './require_app'
require_app

run WiseTube::Api.freeze.app
