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

  embeds_many :gem_entries
  alias_method :gems, :gem_entries

  index [[:owner, Mongo::ASCENDING], [:name, Mongo::ASCENDING]], unique: true

  validates_presence_of :owner
  validates_presence_of :name
  validates_format_of :url, with: %r{^https?://github\.com/.*}

  def to_s
    "#{owner}/#{name}"
  end

  # Creates or updates a record based on a payload from a GitHub post-commit
  # hook
  #
  # @param [String] payload Raw payload string, to be parsed into JSON
  # @return [Repository] saved repository instance
  def self.from_payload(payload)
    return unless payload.is_a?(String)

    begin
      payload = Payload.new(payload)

      if repo = payload.repository
        return if repo['private']

        fields = %w(owner name description fork url homepage watchers forks)
        repo.select! { |k,v| fields.include? k }
        repo['owner'] = repo['owner']['name']

        record = find_or_initialize_by(owner: repo['owner'], name: repo['name'])
        record.queue_gemfile_update if record.new_record? || payload.modified_gemfile?
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
      new_gems = JSON.parse(gemstr)

      # Remove old gem entries before we add new ones
      self.gems.each(&:destroy) if new_gems.length > 0

      new_gems.each do |gem|
        self.gems.create(name: gem['name'], version: gem['version'])
      end
    rescue JSON::ParserError => ignored
    end
  end

  # Enqueues a {GemfileJob} for this record
  def queue_gemfile_update
    Delayed::Job.enqueue GemfileJob.new(self.id)
  end
end
