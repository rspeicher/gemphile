class Repository
  include Mongoid::Document
  include Mongoid::Timestamps

  field :owner,       type: String
  field :name,        type: String
  field :description, type: String
  field :fork,        type: Boolean, default: false
  field :url,         type: String
  field :homepage,    type: String
  field :watchers,    type: Integer, default: 1
  field :forks,       type: Integer, default: 1

  index [[:owner, Mongo::ASCENDING], [:name, Mongo::ASCENDING]], unique: true

  embeds_many :gem_entries
  alias_method :gems, :gem_entries

  # Creates or updates a record based on a payload from a GitHub post-commit
  # hook
  #
  # @param [String] payload Raw payload string, to be parsed into JSON
  # @return [Repository] saved repository instance
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

  # Updates embeded {Gem} documents based on a parsing of a Gemfile by {GemfileJob}
  #
  # @param [String] Raw output string, to be parsed into JSON
  def populate_gems(gemstr)
    return unless gemstr.is_a?(String)

    begin
      gems = JSON.parse(gemstr)

      # Remove old gem entries before we add new ones
      self.gems.each(&:destroy) if gems.length > 0

      gems.each do |gem|
        self.gems.create(name: gem['name'], version: gem['version'])
      end
    rescue JSON::ParserError => ignored
    end
  end
end
