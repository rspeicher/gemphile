module Views
  class Index < Layout
    def gems
      GemCount.order_by([[:count, :desc], [:name, :asc]]).limit(100).to_ary
    end

    def repos
      Repository.limit(10).order_by(:updated_at, :desc).to_ary
    end
  end
end
