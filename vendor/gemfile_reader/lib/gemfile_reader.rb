if [:Gemphile, :Repository, :GemCount].any? { |o| Object.const_defined?(o) }
  puts "GemfileReader must be run outside the Gemphile environment."
  exit
end

# = GemfileReader
#
# Reads a Gemfile definition from a file and returns information about
# the gems specified.
class GemfileReader
  # Represents a single <tt>gem</tt> entry in a gemfile
  class Entry < Struct.new(:name, :version, :path, :git)
    # Converts the object to a <tt>Hash</tt>
    def to_hash
      self.members.zip(self.values).each_with_object({}) { |v,o| o[v[0]] = v[1] }
    end
  end

  # Read a specified Gemfile, evaluating its contents inside an instance of
  # {GemfileReader} and returning an array of {Entry} instances.
  #
  # @param [String] filename
  # @return [Array] Array of {Entry} instances
  def self.evaluate(file_contents)
    gemfile = Sandbox.new

    file_contents = scrub(file_contents)

    # Even after scrubbing the file contents above, we still
    # want to evaluate the file in an elevated safety environment
    # to avoid people doing nasty things
    isolated do
      gemfile.instance_eval(file_contents)
    end

    gemfile.gems
  end

  def self.isolated(&block)
    proc {
      $SAFE = 3

      yield if block_given?
    }.call
  end

  private

  # Scrub Gemfile contents of some specific potentially nasty things
  def self.scrub(contents)
    contents.
      split("\n").
      # Select only "gem ..." lines, ignoring multiple commands on a single line
      select { |l| l.strip =~ /^gem [^;\$]+$/ }.

      # Prevents a SecurityError when accessing ENV
      each { |l| l.gsub!(/ENV[^\s]+/, '""') }.

      # Join it back together and untaint
      join("\n").untaint
  end

  class Sandbox
    # The only options to `gem` we actually care about
    VALID_OPTIONS = [:path, :git].freeze

    # @attr [Array]
    attr_reader :gems

    def initialize
      @gems = []
    end

    protected

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
end
