module Views
  class GemInfo < Layout
    def gem
      @gem
    end

    def repos
      Repository.with_gem(@gem).by_popularity.limit(50).to_ary.
        map { |r| r.description = r.description[0..100] rescue ""; r }
    end
  end
end
