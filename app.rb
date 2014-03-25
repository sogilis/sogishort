require "bundler"
Bundler.require
include Sprockets::Helpers

require_relative 'lib/storage'

class App < Sinatra::Base

  def initialize(app = nil)
    super(app)

    @storage = Storage.new
  end

  set :sprockets, Sprockets::Environment.new(root)


  post '/' do
    url = params[:url]
    hash = @storage.write_link url
    redirect to("/v/#{hash}")
  end

  get '/' do
    haml :index
  end

  get '/list' do
    haml :list, :locals => {:base => request.url.gsub(request.path, ''), :links => @storage.get_links}
  end

  get '/v/:hash' do |hash|
    url = @storage.get_url(hash)
    haml :link, :locals => {:base => request.url.gsub(request.path, ''), :url => url, :hash => hash}
  end

  get '/:hash' do |hash|
    redirect @storage.get_url(hash), 303
  end
end
