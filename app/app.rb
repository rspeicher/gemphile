require 'app/libraries'

module Gemphile
  GITHUB_USER = /^([^-][a-zA-Z0-9\-]+)$/
  GITHUB_REPO = /^([^-][a-zA-Z0-9\-]+)\/([^\/]+)$/

  class App < Sinatra::Base
    use Rack::Flash, :accessorize => [:notice, :error]
    register Mustache::Sinatra

    dir = File.dirname(File.expand_path(__FILE__))

    set :public,   "#{dir}/public"
    set :root,     RACK_ROOT
    set :app_file, __FILE__
    set :static,   true
    set :sessions, true

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

    # Manually add a username or repository to be indexed
    post '/add' do
      if params['repo'] =~ GITHUB_USER
        Delayed::Job.enqueue UserJob.new(params['repo'])
        status(200)
      elsif params['repo'] =~ GITHUB_REPO
        Delayed::Job.enqueue RepositoryJob.new(params['repo'])
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
