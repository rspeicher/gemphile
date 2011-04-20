module Views
  class Layout < Mustache
    def development?
      RACK_ENV == 'development' ? true : nil
    end

    def production?
      RACK_ENV == 'production' ? true : nil
    end
  end
end
