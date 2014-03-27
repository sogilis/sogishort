require_relative 'kvstore'
require 'redis'

class RedisKVStore < KVStore
  def initialize
    url = ENV['REDISTOGO_URL'] || ENV['REDIS_URL']
    @redis = Redis.new :url => url
  end

  # @param [String] key
  # @return [Bool]
  def exists?(key)
    !get(key).nil?
  end

  # @param [String] key
  # @return [String]
  def get(key)
    @redis.get key
  end

  # @param [String] key
  # @param [String] value
  # @return [String] value
  def set(key, value)
    @redis.set key, value
    value
  end

  def multi_set()
    @redis.multi do
      yield
    end
  end

  # @param [String] key
  # @param [String] value
  def add(key, value)
    set key, value
  end

  # @param [String] key
  def incr(key)
    @redis.incr key
  end

  # @param [String] key_prefix
  # @return [Array]
  def multi_get_under(key_prefix)
    keys = @redis.keys "#{key_prefix}/*"
    keys.inject([]) do |values, key|
      values << {:key => key, :value => @redis.get(key)}
    end
  end
end
