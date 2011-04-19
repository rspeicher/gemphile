module Views
  class Layout < Mustache
    def development?
      RACK_ENV == 'development' ? true : nil
    end
  end
end
