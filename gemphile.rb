require 'bundler/setup'

require 'delayed_job'
require 'delayed_job_mongoid'
require 'json'
require 'mongoid'
require 'sinatra/base'

require_relative 'jobs/gemfile_job'
require_relative 'models/all'

class Gemphile < Sinatra::Base
  configure do
    Mongoid.configure do |config|
      config.master = Mongo::Connection.new.db("gemphile_#{ENV['RACK_ENV']}")
      config.allow_dynamic_fields = false
    end
  end

  post '/push' do
    if repo = Repository.from_payload(params['payload'])
      Delayed::Job.enqueue GemfileJob.new(repo.id)
      status(200)
    else
      status(500)
    end
  end
end