REPO_PATH='links.git'
AUTHOR_MAIL='yves@sogilis.com'
AUTHOR_NAME='Yves'

class Git

  def initialize()
    if File.exist? REPO_PATH
      @repository = Rugged::Repository.new REPO_PATH
    else
      @repository = Rugged::Repository.init_at REPO_PATH, :bare
    end
  end

  # @param [String] message
  def write(message = nil)
    index = get_index
    yield index if block_given?
    commit_head index.write_tree(@repository), message
  end

  # @param [Hash] entry
  def tree entry
    @repository.lookup entry[:oid]
  end

  def read(oid)
    @repository.read oid
  end

  # @param [String] path
  # @param [String, nil] rev
  # @return [String]
  def read_blob(path, rev = nil)
    return nil if @repository.empty?
    index = get_index rev
    obj = index[path]
    return nil if obj.nil?
    oid = obj[:oid]
    @repository.read(oid).data
  end

  # @param [Rugged::Tree] tree
  # @param [String] path
  def read_blob_relative(tree, path)
    return nil if @repository.empty?
    oid = recurs_get_oid tree, path.split('/')
    @repository.read(oid).data
  end

  # @param [String] path
  # @param [String, nil] rev
  # @return [Rugged::Tree, nil]
  def read_tree(path, rev = nil)
    read_tree_relative get_tree(rev), path
  end

  # @param [Rugged::Tree] tree
  # @param [String] path
  def read_tree_relative(tree, path)
    return nil if @repository.empty?
    oid = recurs_get_oid tree, path.split('/')
    return nil unless oid
    @repository.lookup oid
  end

  # @param [Hash] tree
  # @return [Rugged::Tree]
  def read_children(tree_entry)
    tree(tree_entry).each do |entry|
      obj = @repository.lookup entry[:oid]
      yield entry[:name], obj
    end
  end

  def get_tree(rev = nil)
    rev ||= @repository.head.target
    @repository.lookup(rev).tree
  end

  # @param [Rugged::Tree] tree
  # @param [Array<String>] paths
  def recurs_get_oid tree, paths
    key = paths.shift
    return nil if tree[key].nil?
    oid = tree[key][:oid]
    return oid if paths.empty?
    recurs_get_oid @repository.lookup(oid), paths
  end

  # @param [String] content
  # @param [String] path
  # @return [Hash]
  def blob(content, path)
    {:path => path, :oid => write_blob(content), :mode => 0100644}
  end

  def commit_head(tree, message = nil)
    parents = @repository.empty? ? [] : [@repository.head.target]
    commit tree, message, parents
  end

  def commit(tree, message = nil, parents = [])
    options = {}
    options[:tree] = tree
    options[:author] = {:email => AUTHOR_MAIL, :name => AUTHOR_NAME, :time => Time.now}
    options[:committer] = {:email => AUTHOR_MAIL, :name => AUTHOR_NAME, :time => Time.now}
    options[:message] ||= message
    options[:parents] = parents
    options[:update_ref] = 'HEAD'

    Rugged::Commit.create @repository, options
  end

  # @param [String] content
  # @return [String]
  def write_blob(content)
    @repository.write content, :blob
  end

  # @param [String] rev
  # @return [Rugged::Index]
  def get_index(rev = nil)
    index = Rugged::Index.new
    unless @repository.empty?
      tree = get_tree rev
      index.read_tree tree
    end
    index
  end
end
