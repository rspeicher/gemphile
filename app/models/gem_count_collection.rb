# = GemCountCollection
#
# Helper module to store a collection containing gem usage counts.
#
# Thanks to https://github.com/wilkerlucio/mongoid_taggable for a starting
# point.
module GemCountCollection
  def self.included(base)
    base.after_save do |document|
      document.class.save_gems_index!
    end

    base.after_destroy do |document|
      document.class.save_gems_index!
    end

    base.extend(ClassMethods)
  end

  module ClassMethods
    def gem_counts
      db = Mongoid::Config.master
      db.collection(gems_index_collection).find.each_with_object([]) do |r, o|
        o << {name: r['_id'], count: r['value'].to_i}
      end
    end

    def gems_index_collection
      "#{collection_name}_gem_counts_index"
    end

    def save_gems_index!
      db = Mongoid::Config.master
      coll = db.collection(collection_name)

      map = "function() {
        if (!this.gem_entries) {
          return;
        }

        for (index in this.gem_entries) {
          emit(this.gem_entries[index].name, 1);
        }
      }"

      reduce = "function(previous, current) {
        var count = 0;

        for (index in current) {
          count += current[index]
        }

        return count;
      }"

      coll.map_reduce(map, reduce, :out => gems_index_collection)
    end
  end
end
