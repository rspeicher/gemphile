module Views
  class Layout < Mustache
    def development?
      Gemphile::App.development?
    end

    def production?
      Gemphile::App.production?
    end

    def flash
      @flash
    end
  end
end
