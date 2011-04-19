# Interface to the repositories_gem_count_index collection
#
# See {GemCountCollection}
class GemCount
  include Mongoid::Document

  field :value, type: Integer

  store_in :repositories_gem_counts_index

  # FIXME: No idea why the Integer above isn't taking
  def value
    read_attribute(:value).to_i
  end

  alias_method :name, :id
  alias_method :count, :value
end
