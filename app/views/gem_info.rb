module Views
  class GemInfo < Layout
    def gem
      @gem
    end

    def repos
      Repository.where('gem_entries.name' => @gem).
        order_by([[:watchers, Mongo::DESCENDING], [:forks, Mongo::DESCENDING]]).
        limit(50).to_ary.
        map { |r| r.description = r.description[0..100]; r }
    end
  end
end
