require 'app/libraries'

module Gemphile
  class App < Sinatra::Base
    configure do
      Mongoid.configure do |config|
        config.master = Mongo::Connection.new.db("gemphile_#{ENV['RACK_ENV']}")
        config.allow_dynamic_fields = false
        config.autocreate_indexes   = true unless production?
      end
    end

    get '/' do
      "Hello World"
    end

    post '/push' do
      if repo = Repository.from_payload(params['payload'])
        status(200)
      else
        status(500)
      end
    end
  end
end
