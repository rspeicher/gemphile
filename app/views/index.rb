module Views
  class Index < Layout
    def gems
      GemCount.order_by([:value, Mongo::DESCENDING]).limit(10).all.to_a
    end
  end
end
