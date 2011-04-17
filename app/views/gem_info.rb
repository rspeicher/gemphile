module Views
  class GemInfo < Layout
    def gem
      @gem
    end

    def repos
      Repository.where('gem_entries.name' => @gem).to_ary
    end
  end
end
