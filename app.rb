require "bundler"
Bundler.require
include Sprockets::Helpers

require_relative 'lib/linksstorage'

class App < Sinatra::Base

  def initialize(app = nil)
    super(app)

    @storage = LinksStorage.new
  end

  set :sprockets, Sprockets::Environment.new(root)


  post '/' do
    url = params[:url]
    hash = @storage.write_link url
    haml :link, :locals => {:url => url, :hash => hash}
  end

  get '/:hash' do |hash|
    redirect @storage.get_url(hash), 303
  end

  get '/' do
    haml :index
  end
end
