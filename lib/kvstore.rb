class KVStore
  # @param [String] key
  # @return [Bool]
  def exists?(key)
    raise NotImplementedError
  end

  # @param [String] key
  # @return [String]
  def get(key)
    raise NotImplementedError
  end

  # @param [String] key
  # @param [String] value
  # @return [String] value
  def set(key, value)
    raise NotImplementedError
  end

  def multi_set()
    raise NotImplementedError
  end

  # @param [String] key
  # @param [String] value
  def add(key, value)
    raise NotImplementedError
  end

  # @param [String] key
  def incr(key)
    raise NotImplementedError
  end

  # @param [String] key_prefix
  # @return [Array]
  def multi_get_under(key_prefix)
    raise NotImplementedError
  end
end
