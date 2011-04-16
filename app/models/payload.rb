# Interface to a GitHub post-receive payload
class Payload
  def initialize(str)
    @payload = JSON.parse(str)
    self
  end

  # @return [Hash]
  def repository
    @payload['repository']
  end

  # @return [Hash]
  def commits
    @payload['commits']
  end

  # Checks through {commits} for any modifications to Gemfile
  #
  # Checks additions, removals and modifications
  #
  # @return [Boolean]
  def modified_gemfile?
    commits.any? do |c|
      c['added'].include?('Gemfile') ||
      c['modified'].include?('Gemfile') ||
      c['removed'].include?('Gemfile')
    end
  end
end
