class GemfileJob < Struct.new(:id)
  def perform
    repo = Repository.find(id)
    puts "Updating #{repo.to_s}"
    url  = repo.url + '/raw/HEAD/Gemfile'

    filename = "tmp/#{object_id}.gemfile"

    # Make sure Gemfile exists
    if Curl::Easy.http_head(url).response_code == 200
      puts "  Gemfile exists, downloading"

      # Download it
      body = Curl::Easy.http_get(url).body_str
      File.open(filename, 'w') { |f| f.puts body }

      # Run it through GemfileReader
      puts "  Reading Gemfile"
      gems = `vendor/gemfile_reader/bin/gemfile_reader #{filename}`.strip

      # Pass the returned JSON string to populate_gems
      puts "  Populating gems"
      repo.populate_gems(gems)

      # Remove the local file
      File.unlink(filename) if File.exists?(filename)
    end
  end
end
