require 'logger'

class GemfileJob < Struct.new(:id)
  # Raised when a repository's Gemfile 404s
  class GemfileError < IOError; end

  # Raised when a repository's gemspec 404s
  class GemspecError < IOError; end

  def logger
    unless @logger
      @logger = Logger.new(STDOUT)
      @logger.datetime_format = ''
    end
    @logger
  end

  def logger=(logger)
    @logger = logger
  end

  def perform
    repo = Repository.find(id)
    logger.info "Updating #{repo.to_s}"

    begin
      gems = process_gemfile(repo)

      # Pass the returned JSON string to populate_gems
      logger.info "  Populating gems"
      repo.populate_gems(gems)
    rescue GemfileError, GemspecError => e
      logger.error "  #{e.message}"
    end
  end

  # Downloads and processes a <tt>Gemfile</tt> for the given repository
  #
  # @param [Repository] repo
  # @return [String] JSON-ready string returned by {gemfile_reader}
  # @raises [GemfileError] When remote Gemfile not found
  def process_gemfile(repo)
    remote = repo.url + "/raw/HEAD/Gemfile"
    local  = "#{RACK_ROOT}/tmp/#{self.object_id}.gemfile"

    if remote_file_exists?(remote)
      logger.info "  Gemfile exists; downloading"
      body = remote_read(remote)

      if body =~ /^gemspec$/m
        # TODO: Currently these are mutually exclusive. Do we want to support definitions in both?
        # TODO: Add repo field saying it uses gemspec to avoid this charade in the future?
        logger.info "  Gemfile references gemspec"
        return process_gemspec(repo)
      else
        logger.info "  Processing Gemfile"
        return write_and_process(local, body)
      end
    else
      raise GemfileError, "#{remote} does not exist"
    end
  end

  # Downloads and processes a <tt>gemspec</tt> file for the given repository
  #
  # @param [Repository] repo
  # @return [String] JSON-ready string returned by {gemfile_reader}
  # @raises [GemspecError] When remote gemspec file not found
  def process_gemspec(repo)
    remote = repo.url + "/raw/HEAD/#{repo.name}.gemspec"
    local  = "#{RACK_ROOT}/tmp/#{self.object_id}.gemspec"

    if remote_file_exists?(remote)
      logger.info "  #{repo.name}.gemspec exists; downloading"
      body = remote_read(remote)

      logger.info "  Processing gemspec"
      return write_and_process(local, body)
    else
      raise GemspecError, "#{remote} does not exist"
    end
  end

  protected

  # Writes a remote file body to a local file, processes that file through
  # {gemfile_reader} and then deletes the local file, returning the result of
  # {gemfile_reader}
  #
  # @param [String] filename
  # @param [String] body
  # @return [String] {gemfile_reader} result
  def write_and_process(filename, body)
    # Write the file and run it through gemfile_reader
    File.open(filename, 'w') { |f| f.puts body }
    gems = `#{RACK_ROOT}/vendor/gemfile_reader/bin/gemfile_reader #{filename}`.strip
    File.unlink(filename) if File.exists?(filename)

    gems
  end

  def remote_file_exists?(url)
    Curl::Easy.http_head(url).response_code == 200
  end

  def remote_read(url)
    Curl::Easy.http_get(url).body_str
  end
end
