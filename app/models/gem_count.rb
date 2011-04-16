class GemCount
  include Mongoid::Document

  field :name, type: String
  field :count, type: Integer, default: 0

  index :name, unique: true
  key :name

  def self.increment(name)
    self.update_count(name, 1)
  end

  def self.decrement(name)
    self.update_count(name, -1)
  end

  def self.update_count(name, value)
    gc = self.find_or_initialize_by(name: name)

    count = gc.count+value < 0 ? 0 : gc.count+value
    gc.update_attribute(:count, count)

    gc
  end
end
