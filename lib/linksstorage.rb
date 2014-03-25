require_relative 'git'

class LinksStorage < Git

  # @param [String] link
  def write_link(link)
    hash = nil
    write "add link" do |index|
      oid = write_blob(link)
      hash = oid[0..4]
      index.add blob_with_oid(oid, hash)
    end
    hash
  end

  # @param [String] hash
  def get_url(hash)
    read_blob hash
  end

  def get_links
    result = []
    get_tree.each do |entry|
      url = @repository.read(entry[:oid]).data
      hash = entry[:name]
      result << {:url => url, :hash => hash}
    end
    result
  end

private

  # @param [String] oid
  # @param [String] path
  # @return [Hash]
  def blob_with_oid(oid, path)
    {:path => path, :oid => oid, :mode => 0100644}
  end
end