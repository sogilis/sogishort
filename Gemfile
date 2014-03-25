source "https://rubygems.org"
ruby '2.0.0'

gem "sinatra", :require => "sinatra/base"

gem "sprockets",         "~> 2.10"
gem "sprockets-helpers", "~> 1.1"
gem "sprockets-sass",    "~> 1.0"
gem "sass",              "~> 3.2"
gem "coffee-script",     "~> 2.2"
gem "uglifier",          "~> 2.4"

gem "rugged", git: 'git://github.com/libgit2/rugged.git', branch: 'development', submodules: true

gem 'haml'

group :test, :development do
  gem "guard-sprockets2"
  gem "rake"
  gem "rack-livereload"
  gem 'guard-livereload', require: false
  # gem "rb-fsevent"
  # gem "growl_notify"
end
