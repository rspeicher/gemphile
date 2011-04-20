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

namespace :deploy do
  task :start, :roles => :app do
    run "cd #{current_release} && bundle exec thin -C #{shared_path}/thin.yml start"
  end

  task :stop, :roles => :app do
    run "cd #{current_release} && bundle exec thin -C #{shared_path}/thin.yml stop"
  end

  task :restart, :roles => :app do
    run "cd #{current_release} && bundle exec thin -C #{shared_path}/thin.yml restart"
  end

  desc 'Symlink the thin config'
  task :symlink_settings, :roles => :app do
    run "ln -s #{shared_path}/thin.yml #{current_release}/config/thin.yml"
  end
end

# DelayedJob
namespace :delayed_job do
  def rack_env
    fetch(:rails_env, false) ? "RACK_ENV=#{fetch(:rails_env)}" : ''
  end

  def roles
    fetch(:delayed_job_server_role, :app)
  end

  desc "Stop the delayed_job process"
  task :stop, :roles => lambda { roles } do
    run "cd #{current_release} && #{rack_env} bundle exec bin/gemphile_worker stop"
  end

  desc "Start the delayed_job process"
  task :start, :roles => lambda { roles } do
    run "cd #{current_release} && #{rack_env} bundle exec bin/gemphile_worker start"
  end

  desc "Restart the delayed_job process"
  task :restart, :roles => lambda { roles } do
    run "cd #{current_release} && #{rack_env} bundle exec bin/gemphile_worker restart"
  end
end

after "deploy",         "deploy:symlink_settings"

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

after "deploy",         "deploy:cleanup"

require 'bundler/capistrano'
