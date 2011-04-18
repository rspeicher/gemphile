class GemfileJob < Struct.new(:id)
  def perform
    repo = Repository.find(id)
    puts "Updating #{repo.to_s}"
    url  = repo.url + '/raw/HEAD/Gemfile'

    filename = "#{RACK_ROOT}/tmp/#{object_id}.gemfile"

    # Make sure Gemfile exists
    if remote_file_exists?(url)
      puts "  Gemfile exists, downloading"

      # Download it
      body = remote_read(url)

      if body =~ /^gemspec$/m
        puts "  Gemfile references gemspec"

        # Download the gemspec
        # TODO: Any examples of using different repo and gem names?
        url = repo.url + "/raw/HEAD/#{repo.name}.gemspec"
        if remote_file_exists?(url)
          puts "  #{repo.name}.gemspec exists, downloading"

          # Gemspec overrides Gemfile, so let's get that instead
          # TODO: Allow gems in the Gemfile AND in the gemspec?
          body = remote_read(url)

          # Remove the downloaded Gemfile then change the filename we pass to gemfile_reader
          File.unlink(filename) if File.exists?(filename)
          filename.gsub!(/\.gemfile$/, '.gemspec')

          puts "  Reading gemspec"

          # TODO: Do we want to store that this repo uses a gemspec to avoid this charade in the future?
        else
          "  ** Failed to download #{repo.name}.gemspec"
        end
      else
        puts "  Reading Gemfile"
      end

      # Write the file and run it through gemfile_reader
      File.open(filename, 'w') { |f| f.puts body }
      gems = `#{RACK_ROOT}/vendor/gemfile_reader/bin/gemfile_reader #{filename}`.strip

      # Pass the returned JSON string to populate_gems
      puts "  Populating gems"
      repo.populate_gems(gems)

      # Remove the local file
      File.unlink(filename) if File.exists?(filename)
    end
  end

  protected

  def remote_file_exists?(url)
    Curl::Easy.http_head(url).response_code == 200
  end

  def remote_read(url)
    Curl::Easy.http_get(url).body_str
  end
end
