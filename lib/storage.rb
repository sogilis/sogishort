require_relative 'git'

class Storage < Git

  LINKS_PATH = 'links'

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