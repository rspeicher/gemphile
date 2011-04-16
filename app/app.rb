require 'app/libraries'

module Gemphile
  class App < Sinatra::Base
    post '/push' do
      if repo = Repository.from_payload(params['payload'])
        status(200)
      else
        status(500)
      end
    end
  end
end
