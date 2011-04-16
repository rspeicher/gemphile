class GemEntry
  include Mongoid::Document

  embedded_in :repository

  field :name,    type: String
  field :version, type: String

  key :name

  after_save     :increment_count
  before_destroy :decrement_count

  protected

  def increment_count
    GemCount.increment(self.name)
  end

  def decrement_count
    GemCount.decrement(self.name)
  end
end
