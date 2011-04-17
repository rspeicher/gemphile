module Views
  class Index < Layout
    def gems
      # TODO: Limit?
      Repository.gem_counts.sort { |a, b| b[:count] <=> a[:count] }
    end

    def repos
      Repository.limit(10).order_by(:updated_at, :desc).to_ary
    end
  end
end
