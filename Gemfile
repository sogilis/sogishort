source "https://rubygems.org"
ruby '2.2.4'

gem "sinatra", :require => "sinatra/base"

gem "sprockets",         "~> 2.10"
gem "sprockets-helpers", "~> 1.1"
gem "sprockets-sass",    "~> 1.0"
gem "sass",              "~> 3.2"
gem "coffee-script",     "~> 2.2"
gem "uglifier",          "~> 2.4"

gem "rugged",            "~> 0.19"
gem 'bcrypt', '~> 3.1.7'
gem 'base62', '~> 1.0.0'
gem 'redis'

gem 'haml'

group :test, :development do
  gem "guard-sprockets2"
  gem "rake"
  gem "rack-livereload"
  gem 'guard-livereload', require: false
  # gem "rb-fsevent"
  # gem "growl_notify"

  gem "cucumber"
  gem "rspec"
end
