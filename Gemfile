# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'json'
gem 'puma', '~>5'
gem 'roda', '~>3'

# Configuration
gem 'figaro', '~>1'
gem 'rake', '~>13'

# Security
gem 'bundler-audit'
gem 'rbnacl', '~>7'

# Database
gem 'hirb', '~>0'
gem 'sequel', '~>5'

group :production do
  gem 'pg'
end

# External Services
gem 'http'

# Test coverage
gem 'simplecov'

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'webmock'
end

# Debugging
gem 'pry' # necessary for rake console
gem 'rack-test'

# Application
gem 'google-apis-youtube_v3', '~>0.17.0'

# Development
group :development do
  gem 'rerun'

  # Quality
  gem 'rubocop'
  gem 'rubocop-performance'
end

group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3'
end
