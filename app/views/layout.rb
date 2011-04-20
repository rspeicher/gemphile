module Views
  class Layout < Mustache
    def development?
      Gemphile::App.development?
    end

    def production?
      Gemphile::App.production?
    end
  end
end
