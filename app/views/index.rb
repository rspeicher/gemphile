module Views
  class Index < Layout
    def gems
      # FIXME: This is going to become a really, really inefficient way to do this
      Repository.gem_counts.sort { |a, b| b[:count] <=> a[:count] }[0...10]
    end

    def repos
      Repository.limit(10).order_by(:updated_at, :desc).to_ary
    end
  end
end
