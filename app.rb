require "bundler"
Bundler.require
include Sprockets::Helpers

require 'uri'

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
    haml :index, :locals => {:bookmark => bookmark(path(request))}
  end

  get '/list' do
    protected!
    links = @storage.links
    links_with_hits = links.map do |link|
      link[:hits] = @storage.hits link[:hash]
      link
    end
    haml :list, :locals => {:base => http_path(request), :links => links_with_hits}
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
    protected!
    url = @storage.url hash
    hits = @storage.hits hash
    haml :link, :locals => {:base => http_path(request), :url => url, :hash => hash, :hits => hits}
  end

  get '/add' do
    protected!
    url = params[:url]
    hash = @storage.add_link url
    short = "#{http_path(request)}/#{hash}"
    halt 200, {'Content-Type' => 'text/plain'}, short
  end

  get '/short' do
    protected!
    url = params[:url]
    hash = @storage.add_link url
    short = "alert(\"#{http_path(request)}/#{hash}\");"
    halt 200, {'Content-Type' => 'text/javascript'}, short
  end

  get '/favicon.ico' do

  end

  get '/dump' do
    protected!
    export = @storage.dump.inject(["hash;url;hits"]) do |export, datas|
      export << "#{datas[:hash]};\"#{datas[:url]}\";#{datas[:hits]}"
    end
    halt 200, {'Content-Type' => 'text/csv'}, export.join("\n")
  end

  get '/:hash' do |hash|
    @storage.incr_hits hash
    redirect @storage.url(hash), 302
  end

private

  def path(request, scheme = '')
    path = "#{scheme}//#{request.host}"
    path += ":#{request.port}" if request.port != 80 && request.port != 443
    path
  end

  def http_path(request)
    path(request, 'http:')
  end

  def bookmark(base_path)
    js_definition = <<EOF
function () {
document.body.appendChild((function() {
var s = document.createElement('script');
s.src = '#{base_path}/short?url=' + encodeURIComponent(location.href);
return s;
})());
}
EOF
    URI::encode(js_definition.gsub(/\n/, ''))
  end
end
