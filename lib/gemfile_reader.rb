# = GemfileReader
#
# Reads a Gemfile definition from a file and returns information about
# the gems specified.
class GemfileReader
  # Represents a single <tt>gem</tt> entry in a gemfile
  class Entry < Struct.new(:name, :version, :type, :path, :group, :platform)
  end

  class << self
    def read(filename)
      File.open(filename, 'rb') { |f| f.read }
    end

    # Read a specified Gemfile, evaluating its contents inside an instance of
    # {GemfileReader} and returning an array of {Entry} instances.
    #
    # @param [String] filename
    # @return [Array] Array of {Entry} instances
    def evaluate(filename)
      gemfile = new
      gemfile.instance_eval(read(filename))
      gemfile.gems
    end
  end

  # @attr [Array]
  attr_reader :gems

  def initialize
    @gems          = []
    @current_group = nil
  end

  protected

  def method_missing(m, *args)
    # Ignored
  end

  def gem(name, version = nil, options = {})
    g = Entry.new

    g.name    = name
    g.version = version
    options.each_pair { |k,v| g[k] = v }

    @gems << g
  end
end
