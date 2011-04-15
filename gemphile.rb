require 'bundler/setup'

require 'delayed_job'
require 'delayed_job_mongoid'
require 'json'
require 'mongoid'
require 'sinatra/base'

require 'models/all'

class Gemphile < Sinatra::Base
  configure do
    Mongoid.configure do |config|
      config.master = Mongo::Connection.new.db("gemphile_#{ENV['RACK_ENV']}")
      config.allow_dynamic_fields = false
    end
  end

  post '/push' do
    Repository.from_payload(params[:payload])
    status(200)
  end
end
