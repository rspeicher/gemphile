class RepositoryJob < Struct.new(:repo)
  def perform
    if response = Curl::Easy.perform("http://github.com/api/v2/json/repos/show/#{repo}")
      Repository.from_payload(response.body_str)
    end
  end
end
