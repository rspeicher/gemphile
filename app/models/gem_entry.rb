class GemEntry
  include Mongoid::Document

  embedded_in :repository

  field :name,    type: String
  field :version, type: String
end
