class GemfileJob < Struct.new(:repo_id)
  def perform
    repo = Repository.find(repo_id)
    url  = "https://github.com/#{repo.owner}/#{repo.name}/raw/HEAD/Gemfile"

    filename = "tmp/#{object_id}.gemfile"

    # Make sure Gemfile exists
    # FIXME: Any easy way to do this without hitting it twice?
    if `curl -I #{url}` =~ /Status: 200 OK/
      # Download it
      `curl #{url} -o #{filename}`

      # Run it through GemfileReader
      gems = `vendor/gemfile_reader/bin/gemfile_reader #{filename}`.strip
      repo.populate_gems(gems)

      `rm -f #{filename}`
    end
  end
end
