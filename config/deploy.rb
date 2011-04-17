$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                               # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.2@gemphile'                 # Or whatever env you want it to run in.

set :application, "gemphile"
set :deploy_to,   "/home/tsigo/rails/#{application}"
set :rails_env,   "production"

set :domain,      "tsigo.com"
set :repository,  "git@tsigo.com:#{application}.git"
set :scm,         'git'
set :branch,      'master'

set :use_sudo, false
set :keep_releases, 3

set :user, 'tsigo'
set :ssh_options, { :forward_agent => true, :keys => "/Users/tsigo/.ssh/id_rsa" }

role :app, domain
role :web, domain
role :db,  domain, :primary => true

# after "deploy:symlink", "deploy:update_crontab"
# namespace :deploy do
#   desc "Update the crontab file"
#   task :update_crontab, :roles => :db do
#     run "cd #{release_path} && bundle exec whenever --update-crontab #{application}"
#   end
# end

after "deploy", "deploy:cleanup"

require 'bundler/capistrano'
