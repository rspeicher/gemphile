module Views
  class GemInfo < Layout
    def gem
      @gem
    end

    def repos
      Repository.where('gem_entries.name' => @gem).order_by([[:watchers, Mongo::DESCENDING], [:forks, Mongo::DESCENDING]]).limit(50).to_ary
    end
  end
end
