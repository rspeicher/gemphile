class UserJob < Struct.new(:user)
  def perform
    if response = Curl::Easy.perform("http://github.com/api/v2/json/repos/show/#{user}")
      Repository.from_user(response.body_str)
    end
  end
end
