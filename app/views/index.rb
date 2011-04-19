module Views
  class Index < Layout
    def gems
      GemCount.order_by([:value, Mongo::DESCENDING]).limit(10).all.to_a
    end

    def repos
      Repository.limit(10).order_by(:updated_at, :desc).to_ary
    end
  end
end
