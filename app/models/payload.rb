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

  # Checks through {commits} for any modifications to Gemfile or gemspec
  #
  # Checks additions, removals and modifications
  #
  # @return [Boolean]
  def modified_gems?
    return unless commits

    commits.any? do |c|
      c['added'].include?('Gemfile') || c['added'].include?(gemspec) ||
      c['modified'].include?('Gemfile') || c['modified'].include?(gemspec) ||
      c['removed'].include?('Gemfile') || c['removed'].include?(gemspec)
    end
  end

  protected

  def gemspec
    return unless repository
    @gemspec_name ||= "#{repository['name']}.gemspec"
  end
end
