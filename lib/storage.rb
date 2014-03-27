require_relative 'url'
require_relative 'kvstore'
require 'bcrypt'

class Storage
  include BCrypt

  LINKS_PATH = 'links'
  SETTINGS_PATH = 'settings'
  USER_PATH = File.join SETTINGS_PATH, 'user'
  PASS_PATH = File.join SETTINGS_PATH, 'password'
  HIT_PATH = 'hit'

  # @param [KVStore] store
  def initialize(store)
    @store = store
  end

  # @param [String] link
  def write_link(link)
    hash = Url.to_hash link
    @store.set link_path(hash), link
    hash
  end

  # @param [String] hash
  def get_url(hash)
    @store.incr hit_path hash
    @store.get link_path hash
  end

  # @param [String] hash
  def hits(hash)
    @store.get hit_path hash
  end

  def get_links
    entries = @store.multi_get_under LINKS_PATH
    entries.inject([]) do |links, link|
      links << {:url => link[:value], :hash => unlink_path(link[:key])}
    end
  end

  def store_settings(user, pass)
    @store.multi_set do
      @store.add USER_PATH, user
      @store.add PASS_PATH, Password.create(pass)
    end
  end

  def configured?
    @store.exists? USER_PATH
  end

  def authenticate(user, pass)
    return false unless configured?
    u = @store.get USER_PATH
    p = Password.new @store.get PASS_PATH
    u == user && p == pass
  end

private

  def link_path(path)
    "#{LINKS_PATH}/#{path}"
  end

  def unlink_path(path)
    path.gsub "#{LINKS_PATH}/", ''
  end

  def hit_path(path)
    "#{LINKS_PATH}/#{path}/#{HIT_PATH}"
  end
end