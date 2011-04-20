module Views
  class SearchResults < Layout
    def query
      @query
    end

    def gems
      GemCount.where(_id: %r{.*#{@query}.*}).order_by([:value, Mongo::DESCENDING]).limit(25).to_a
    end
  end
end
