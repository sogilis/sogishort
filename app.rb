require "bundler"
Bundler.require
include Sprockets::Helpers

require_relative 'lib/storage'
require_relative 'lib/kvstore'
require_relative 'lib/gitkvstore'
require_relative 'lib/rediskvstore'

class App < Sinatra::Base

  def initialize(app = nil)
    super(app)

    if ENV['STORE'] == 'git'
      store = GitKVStore.new
    elsif ENV['STORE'] == 'redis'
      store = RedisKVStore.new
    else
      raise NotImplementedError, 'no store found'
    end
    @storage = Storage.new store
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
    hash = @storage.add_link url
    redirect to("/v/#{hash}")
  end

  get '/' do
    redirect to('/settings') unless @storage.configured?
    protected!
    haml :index
  end

  get '/list' do
    haml :list, :locals => {:base => path(request), :links => @storage.links}
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
    url = @storage.url hash
    hits = @storage.hits hash
    haml :link, :locals => {:base => path(request), :url => url, :hash => hash, :hits => hits}
  end

  get '/add' do
    protected!
    url = params[:url]
    hash = @storage.add_link url
    short = "#{path(request)}/#{hash}"
    halt 200, {'Content-Type' => 'text/plain'}, short
  end

  get '/:hash' do |hash|
    @storage.incr_hits hash
    redirect @storage.url(hash), 303
  end

  def path(request)
    path = "#{request.scheme}://#{request.host}"
    path += ":#{request.port}" if request.port != 80
    path
  end
end
