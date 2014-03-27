require_relative 'kvstore'
require_relative 'git'
require 'thread'

class GitKVStore < KVStore
  def initialize
    @@mutex = Mutex.new

    @git = Git.new
    @index = nil
  end
  # @param [String] key
  # @return [Bool]
  def exists?(key)
    !get(key).nil?
  end

  # @param [String] key
  # @return [String]
  def get(key)
    @git.read_blob key
  end

  # @param [String] key
  # @param [String] value
  # @return [String] value
  def set(key, value)
    @@mutex.synchronize {
      do_set key, value
    }
  end

  def multi_set()
    @git.write "set" do |index|
      @index = index
      yield
    end
    @index = nil
  end

  # @param [String] key
  # @param [String] value
  def add(key, value)
    return if @index.nil?
    index.add @git.blob(value, key)
  end

  # @param [String] key
  def incr(key)
    @@mutex.synchronize {
      val = get key
      do_set key, (val.to_i + 1).to_s
    }
  end

  # @param [String] key_prefix
  # @return [Array]
  def multi_get_under(key_prefix)
    result = []
    entries = @git.read_tree key_prefix
    unless entries.nil?
      entries.each do |entry|
        value = @git.read(entry[:oid]).data
        key = entry[:name]
        result << {:key => key, :value => value}
      end
    end
    result
  end

private

  # @param [String] key
  # @param [String] value
  # @return [String] value
  def do_set(key, value)
    @git.write "set" do |index|
      index.add @git.blob(value, key)
    end
  end
end
