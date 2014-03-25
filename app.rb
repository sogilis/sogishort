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

  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new request.env
      @auth.provided? and @auth.basic? and @auth.credentials and @storage.authenticate(@auth.credentials.first, @auth.credentials.last)
    end
  end

  post '/' do
    protected!
    url = params[:url]
    hash = @storage.write_link url
    redirect to("/v/#{hash}")
  end

  get '/' do
    redirect to('/settings') unless @storage.configured?
    protected!
    haml :index
  end

  get '/list' do
    haml :list, :locals => {:base => request.url.gsub(request.path, ''), :links => @storage.get_links}
  end

  get '/settings' do
    halt 401, "Not authorized\n" if @storage.configured?
    haml :settings
  end

  post '/settings' do
    @storage.store_settings params[:username], params[:password]
    redirect to('/')
  end

  get '/v/:hash' do |hash|
    url = @storage.get_url(hash)
    haml :link, :locals => {:base => request.url.gsub(request.path, ''), :url => url, :hash => hash}
  end

  get '/:hash' do |hash|
    redirect @storage.get_url(hash), 303
  end
end
