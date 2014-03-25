require_relative 'git'
require 'bcrypt'

class Storage < Git
  include BCrypt

  LINKS_PATH = 'links'
  SETTINGS_PATH = 'settings'
  USER_PATH = File.join SETTINGS_PATH, 'user'
  PASS_PATH = File.join SETTINGS_PATH, 'password'

  # @param [String] link
  def write_link(link)
    hash = nil
    write "add link" do |index|
      oid = write_blob(link)
      hash = oid[0..4]
      index.add blob_with_oid(oid, link_path(hash))
    end
    hash
  end

  # @param [String] hash
  def get_url(hash)
    read_blob link_path hash
  end

  def get_links
    result = []
    links = read_tree LINKS_PATH
    links.each do |entry|
      url = @repository.read(entry[:oid]).data
      hash = entry[:name]
      result << {:url => url, :hash => hash}
    end
    result
  end

  def store_settings(user, pass)
    write "store settings" do |index|
      index.add blob(user, USER_PATH)
      index.add blob(Password.create(pass), PASS_PATH)
    end
  end

  def configured?
    !read_blob(USER_PATH).nil?
  end

  def authenticate(user, pass)
    return false unless configured?
    u = read_blob USER_PATH
    p = Password.new read_blob PASS_PATH
    u == user && p == pass
  end

private

  def link_path(path)
    "#{LINKS_PATH}/#{path}"
  end

  # @param [String] oid
  # @param [String] path
  # @return [Hash]
  def blob_with_oid(oid, path)
    {:path => path, :oid => oid, :mode => 0100644}
  end
end