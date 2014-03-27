require_relative 'url'
require 'bcrypt'
require 'redis'

class Storage
  include BCrypt

  LINKS_PATH = 'links'
  SETTINGS_PATH = 'settings'
  USER_PATH = File.join SETTINGS_PATH, 'user'
  PASS_PATH = File.join SETTINGS_PATH, 'password'

  def initialize
    url = ENV['REDISTOGO_URL'] || ENV['REDIS_URL']
    @redis = Redis.new :url => url
  end

  # @param [String] link
  def write_link(link)
    hash = Url.to_hash link
    @redis.set link_path(hash), link
    hash
  end

  # @param [String] hash
  def get_url(hash)
    @redis.get link_path hash
  end

  def get_links
    keys = @redis.keys link_path '*'
    keys.inject([]) do |links, key|
      links << {:url => @redis.get(key), :hash => unlink_path(key)}
    end
  end

  def store_settings(user, pass)
    @redis.multi do
      @redis.set USER_PATH, user
      @redis.set PASS_PATH, Password.create(pass)
    end
  end

  def configured?
    !@redis.get(USER_PATH).nil?
  end

  def authenticate(user, pass)
    return false unless configured?
    u = @redis.get USER_PATH
    p = Password.new @redis.get PASS_PATH
    u == user && p == pass
  end

private

  def link_path(path)
    "#{LINKS_PATH}/#{path}"
  end

  def unlink_path(path)
    path.gsub "#{LINKS_PATH}/", ''
  end
end