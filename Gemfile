source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.3'
gem 'mysql2'

# Use Puma as the app server
gem 'puma', '~> 5.2'

# async jobs - will need at some point, not yet
#gem 'sidekiq'
#gem 'sidekiq-limit_fetch'

# http requests
gem 'faraday'
gem 'typhoeus'

# logging
gem 'lograge'

# config made easy
gem 'dotenv-rails'

gem 'listen', '>= 3.0.5', '< 3.2'

group :production, :staging do
  gem 'gelf'
  # gem 'sidekiq-gelf' # graylog remote logserver
end

group :production, :staging do
  gem "sentry-ruby"
  gem "sentry-rails"
  # gem "sentry-sidekiq"
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rubocop', require: false
  gem 'simplecov', require: false
end

group :test do
  gem 'mocha'
  gem 'webmock'
  gem 'minitest-stub_any_instance'
  gem 'rails-controller-testing'
end

group :development do
  gem 'ed25519'
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'rbnacl-libsodium'
  gem 'rbnacl', '>= 3.2', '< 5.0'
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
end
