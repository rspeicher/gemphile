# = Repository
#
# Contains information about a single GitHub repository and embeds the gems it
# references as {GemEntry} records.
#
# == Data from GitHub
#
# Repositories are only to be created via data from GitHub.
#
# === User API
#
#   >> json = Curl::Easy.perform("http://github.com/api/v2/json/repos/show/tsigo")
#   >> Repository.from_user(json)
#   => ... creates (or updates existing) Repository records
#
# === Repository API
#
#   >> json = Curl::Easy.perform("http://github.com/api/v2/json/repos/show/tsigo/gemphile")
#   >> Repository.from_payload(json)
#   => ... creates one (or updates one existing) Repository record
#
# === Post-receive
#
#   >> Repository.from_payload(params[:payload])
#   => ... creates one (or updates one existing) Repository record
class Repository
  include Mongoid::Document
  include Mongoid::Timestamps

  include GemCountCollection

  field :owner,       type: String
  field :name,        type: String
  field :description, type: String,  default: ""
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

  scope :with_gem, ->(name) { where('gem_entries.name' => name) }
  scope :by_popularity, order_by([[:watchers, Mongo::DESCENDING], [:forks, Mongo::DESCENDING]])

  after_create :queue_gemfile_update

  def to_s
    "#{owner}/#{name}"
  end

  # Process all of the public Ruby repositories for a GitHub user
  #
  # @param [String] json_str Raw JSON string returned by an API call
  def self.from_user(json_str)
    begin
      user = JSON.parse(json_str)

      user['repositories'].each { |repo| self.from_github_repository(repo) }
    rescue JSON::ParserError => ignored
    end
  end

  # Creates or updates a record based on a payload from a GitHub post-commit
  # hook or a GitHub API repository entry
  #
  # Also calls {queue_gemfile_update} if changes to the Gemfile or gemspec were
  # detected.
  #
  # @param [String] payload Raw payload string, to be parsed into JSON
  # @return [Repository] saved repository instance
  def self.from_payload(payload)
    return unless payload.is_a?(String)

    begin
      payload = Payload.new(payload)

      if repo = payload.repository
        record = self.from_github_repository(repo)
        record.queue_gemfile_update if payload.modified_gems?

        record
      end
    rescue JSON::ParserError => ignored
    end
  end

  # Updates embedded {Gem} documents based on a parsing of a Gemfile by {GemfileJob}
  #
  # @param [String] gemstr Raw output string, to be parsed into JSON
  def populate_gems(gemstr)
    return unless gemstr.is_a?(String)

    begin
      new_gems = JSON.parse(gemstr)

      # Remove old gem entries before we add new ones
      self.gems.destroy_all if new_gems.length > 0

      new_gems.each do |gem|
        self.gems.create(name: gem['name'], version: gem['version'])
      end

      # Update GemCount data
      self.save
    rescue JSON::ParserError => ignored
    end
  end

  # Enqueues a {GemfileJob} for this record
  def queue_gemfile_update
    Delayed::Job.enqueue GemfileJob.new(self.id)
  end

  private

  VALID_FIELDS = %w(owner name description fork url homepage watchers forks).freeze

  # Creates or updates a {Repository} record based on a repository payload,
  # either from a GitHub post-receive, or a GitHub API request.
  #
  # @param [Array] repo JSON-parsed repository entry
  # @return [Repository]
  def self.from_github_repository(repo)
    return if repo['private']
    return if repo['fork'] == true
    return if repo['language'] && repo['language'] != 'Ruby'

    repo.select! { |k,v| VALID_FIELDS.include? k }
    repo['owner'] = repo['owner']['name'] unless repo['owner'].is_a?(String)

    record = find_or_initialize_by(owner: repo['owner'], name: repo['name'])
    record.update_attributes(repo)

    record
  end
end
