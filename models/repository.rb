class Repository
  include Mongoid::Document
  include Mongoid::Timestamps

  field :owner,       type: String
  field :name,        type: String
  field :description, type: String
  field :fork,        type: Boolean
  field :url,         type: String
  field :homepage,    type: String
  field :watchers,    type: Integer
  field :forks,       type: Integer

  def self.from_payload(payload)
    return unless payload.is_a?(String)

    begin
      payload = JSON.parse(payload)

      fields = %w(owner name description fork url homepage watchers forks)

      if repo = payload['repository']
        return if repo['private']

        repo.select! { |k,v| fields.include? k }
        repo['owner'] = repo['owner']['name']

        record = find_or_initialize_by(owner: repo['owner'], name: repo['name'])
        record.update_attributes(repo)
        record
      end
    rescue JSON::ParserError => ignored
    end
  end
end
