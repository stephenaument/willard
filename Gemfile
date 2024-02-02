source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby "3.1.3"

gem "bootsnap", require: false
gem "cssbundling-rails"
gem "geocoder"
gem "hashie"
gem "high_voltage"
gem "honeybadger"
gem "httparty"
gem "inline_svg"
gem "jsbundling-rails"
gem "oj"
gem "pg"
gem "puma"
gem "rack-canonical-host"
gem "rack-mini-profiler", require: false
gem "rack-timeout", group: :production
gem "rails", "~> 7.0.0"
gem "recipient_interceptor"
gem "redis", "~> 4.0"
gem "redis-rails"
gem "sassc-rails"
gem "sidekiq"
gem "simple_form"
gem "skylight"
gem "sprockets-rails"
gem "standard", group: :development
gem "stimulus-rails"
gem "title"
gem "turbo-rails"
gem "tzinfo-data", platforms: [:mingw, :x64_mingw, :mswin, :jruby]

group :development do
  gem "listen"
  gem "web-console"
end

group :development, :test do
  gem "awesome_print"
  gem "bullet"
  gem "bundler-audit", ">= 0.7.0", require: false
  gem "factory_bot_rails"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rspec-rails", "~> 5.1"
  gem "suspenders"
end

group :test do
  gem "formulaic"
  gem "launchy"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "timecop"
  gem "webdrivers"
  gem "webmock"
end


