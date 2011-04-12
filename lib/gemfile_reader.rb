# = GemfileReader
#
# Reads a Gemfile definition from a file and returns information about
# the gems specified.
class GemfileReader
  # Represents a single <tt>gem</tt> entry in a gemfile
  class Entry < Struct.new(:name, :version, :path, :git); end

  class << self
    # Read a specified Gemfile, evaluating its contents inside an instance of
    # {GemfileReader} and returning an array of {Entry} instances.
    #
    # @param [String] filename
    # @return [Array] Array of {Entry} instances
    def evaluate(file_contents)
      gemfile = new

      file_contents = scrub(file_contents)

      # Even after scrubbing the file contents above, we still
      # want to evaluate the file in an elevated safety environment
      # to avoid people doing nasty things
      lambda {
        $SAFE = 3
        gemfile.instance_eval(file_contents)
      }.call

      return gemfile.gems
    end

    private

    # Scrub Gemfile contents of some specific potentially nasty things
    def scrub(contents)
      contents.
        split("\n").
        # Select only "gem ..." lines
        select { |l| l.strip =~ /^gem .*$/ }.

        # Prevents a SecurityError when accessing ENV
        each { |l| l.gsub!(/ENV[^\s]+/, '""') }.

        # Join it back together and untaint
        join("\n").untaint
    end
  end

  # The only options to `gem` we actually care about
  VALID_OPTIONS = [:path, :git].freeze

  # @attr [Array]
  attr_reader :gems

  def initialize
    @gems = []
  end

  protected

  def method_missing(m, *args)
    # Ignore everything that's not defined below
  end

  def group(*args, &block)
    yield
  end

  alias_method :groups, :group
  alias_method :platforms, :group

  def gem(name, *options)
    g = Entry.new

    g.name = name

    options.each do |opt|
      if opt.is_a?(String)
        g.version = opt
      elsif opt.is_a?(Hash)
        # Apply remaining options from a Hash
        opt.select! { |k,v| VALID_OPTIONS.include? k }
        opt.each_pair { |k,v| g[k] = v }
      end
    end

    @gems << g
  end
end
