source "https://rubygems.org"

ruby file: "./.ruby-version"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.0"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

gem "money"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

gem "pstore"

group :development, :test do
  # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
  gem "rubocop", require: false
  gem "rubocop-rails-omakase", require: false
  gem "tzinfo-data", platforms: %i[ windows jruby ]

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "factory_bot_rails", "~> 6.4"

  gem "mocha", "~> 2.7"
end

group :sinatra do
  gem "sinatra", "~> 4.1"
  gem "sinatra-contrib", require: [ "sinatra/base", "sinatra/json", "sinatra/namespace" ]
  gem "sqlite3"
  gem "json"
end
