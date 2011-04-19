# A single gem usage inside a {Repository}
#
# We would've just called this "Gem", but that's taken.
class GemEntry
  include Mongoid::Document

  embedded_in :repository

  field :name,    type: String
  field :version, type: String
end
