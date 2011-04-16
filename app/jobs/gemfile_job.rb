class GemfileJob < Struct.new(:repo_id)
  def perform
    repo = Repository.find(repo_id)
    url  = repo.url + '/raw/HEAD/Gemfile'

    filename = "tmp/#{object_id}.gemfile"

    # Make sure Gemfile exists
    if Curl::Easy.http_head(url).response_code == 200
      # Download it
      body = Curl::Easy.http_get(url).body_str
      File.open(filename, 'w') { |f| f.puts body }

      # Run it through GemfileReader
      gems = `vendor/gemfile_reader/bin/gemfile_reader #{filename}`.strip

      # Pass the returned JSON string to populate_gems
      repo.populate_gems(gems)

      # Remove the local file
      File.unlink(filename) if File.exists?(filename)
    end
  end
end
