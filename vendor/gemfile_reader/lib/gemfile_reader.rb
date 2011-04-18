if [:Gemphile, :Repository, :GemCount].any? { |o| Object.const_defined?(o) }
  puts "GemfileReader must be run outside the Gemphile environment."
  exit
end

module GemfileReader
  # Special Array that makes sure the gems added to it are unique by name
  class Gems < Array
    def <<(gem)
      super if self.none? { |g| g.name == gem.name }
    end
  end

  # Represents a single <tt>gem</tt> entry in a gemfile
  class Entry < Struct.new(:name, :version, :path, :git)
    # Converts the object to a <tt>Hash</tt>
    def to_hash
      self.members.zip(self.values).each_with_object({}) { |v,o| o[v[0]] = v[1] }
    end
  end

  protected

  def self.isolated(&block)
    proc {
      $SAFE = 3

      yield if block_given?
    }.call
  end

  # = Gemfile
  #
  # Reads a Gemfile definition and returns information about the gems
  # specified.
  class GemfileReader
    # Processes the contents of a Gemfile, evaluating it inside an instance of
    # {Gemfile} and returning an array of {Entry} instances.
    #
    # @param [String] file_contents
    # @return [Array] Array of {Entry} instances
    def self.evaluate(file_contents)
      gemfile = Gemfile.new

      file_contents = Gemfile.scrub(file_contents)

      # Even after scrubbing the file contents above, we still
      # want to evaluate the file in an elevated safety environment
      # to avoid people doing nasty things
      ::GemfileReader.isolated do
        gemfile.instance_eval(file_contents)
      end

      gemfile.gems
    end

    private

    # Gemfile sandbox
    class Gemfile
      # Scrub file contents of everything except very specific calls
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

      # The only options to `gem` we actually care about
      VALID_OPTIONS = [:path, :git].freeze

      attr_reader :gems

      def initialize
        @gems = Gems.new
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

  # = Gemfile
  #
  # Reads a Gemfile definition and returns information about the gems
  # specified.
  class GemspecReader
    # Processes the contents of a Gemspec, evaluating it inside an instance of
    # {Gemspec} and returning an array of {Entry} instances.
    #
    # @param [String] file_contents
    # @return [Array] Array of {Entry} instances
    def self.evaluate(file_contents)
      gemspec = Gemspec.new

      file_contents = Gemspec.scrub(file_contents)

      ::GemfileReader.isolated do
        gemspec.instance_eval(file_contents)
      end

      gemspec.gems
    end

    private

    # Gemspec sandbox
    class Gemspec
      # Scrub file contents of everything except very specific calls
      def self.scrub(contents)
        contents.
          split("\n").
          # Select only "add_dependency ..." lines, ignoring multiple commands on a single line
          # This will ignore a valid line such as <tt>s.add_dependency"rails"</tt>, but fuck those people.
          select { |l| l.strip =~ /^(\w+)\.add(_development|_runtime)?_dependency(\s|\()[^;\$]+$/ }.

          # Prevents a SecurityError when accessing ENV
          each { |l| l.gsub!(/ENV[^\s]+/, '""') }.

          # Join it back together and untaint
          join("\n").untaint
      end

      attr_reader :gems

      def initialize
        @gems = Gems.new
        @times_missing = 0
      end

      protected

      def method_missing(m, *args)
        if m.to_s =~ /^add(_development|_runtime)?_dependency$/
          @times_missing = 0
          gem(*args)
        elsif @times_missing < 1
          # Don't nest too deeply
          @times_missing += 1

          # Make sure we become the receiver for the next call; essentially
          # makes `s.add_dependency` work because `s` becomes `self`
          self
        else
          nil
        end
      end

      def gem(name, version)
        @gems << Entry.new(name, version)
      end
    end
  end
end
