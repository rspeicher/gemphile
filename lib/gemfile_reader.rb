# = GemfileReader
#
# Reads a Gemfile definition from a file and returns information about
# the gems specified.
class GemfileReader
  # Represents a single <tt>gem</tt> entry in a gemfile
  class Entry < Struct.new(:name, :version, :require, :path, :git, :group, :platforms)
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
    @gems              = []
    @current_groups    = nil
    @current_platforms = nil
  end

  protected

  def method_missing(m, *args)
    # Ignore everything that's not defined below
  end

  def group(*args, &block)
    @current_groups = args
    yield
    @current_groups = nil
  end

  def platforms(*args, &block)
    @current_platforms = args
    yield
    @current_platforms = nil
  end

  def gem(name, *options)
    g = Entry.new

    g.name      = name
    g.version   = options[0].is_a?(String) ? options.shift : nil
    g.group     = @current_groups
    g.platforms = @current_platforms

    # Apply remaining options from a Hash
    if options[0]
      options.shift.each_pair do |k,v|
        # Normalize group to an Array
        if k == :group
          g[k] = [v]
        else
          g[k] = v
        end
      end
    end

    @gems << g
  end
end
