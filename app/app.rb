require 'app/libraries'

module Gemphile
  class App < Sinatra::Base
    register Mustache::Sinatra

    dir = File.dirname(File.expand_path(__FILE__))

    set :public,   "#{dir}/public"
    set :root,     RACK_ROOT
    set :app_file, __FILE__
    set :static,   true

    set :views, "#{dir}/templates"

    set :mustache, {
      :namespace => Object,
      :views     => "#{dir}/views",
      :templates => "#{dir}/templates"
    }

    get '/' do
      mustache :index
    end

    get '/gems/:gem' do
      @gem = params[:gem]
      mustache :gem_info
    end

    get '/search' do
      if GemCount.where(_id: params['q']).count == 1
        redirect to("/gems/#{params['q']}")
      else
        @query = params['q']
        mustache :search_results
      end
    end

    post '/push' do
      if repo = Repository.from_payload(params['payload'])
        status(200)
      else
        status(500)
      end
    end

    not_found do
      mustache :"404"
    end

    error do
      mustache :"500"
    end
  end
end
