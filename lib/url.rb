require 'base62'
require 'zlib'

module Url
  # @param [String] url
  # @return [String]
  def to_hash(url)
    Zlib.crc32(url, 0).base62_encode
  end

  module_function :to_hash
end