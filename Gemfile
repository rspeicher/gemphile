source :rubygems

gem 'sinatra',  '~> 1.2'
gem 'mongoid',  '~> 2.0'
gem 'bson_ext', '~> 1.3'

gem 'curb',                '~> 0.7'
gem 'delayed_job',         '~> 2.1'
gem 'delayed_job_mongoid', '~> 1.0'

group :development, :test do
  gem 'capistrano'
  gem 'mocha'
  gem 'rspec', '~> 2.5'
  gem 'ruby-debug19'
end

group :test do
  gem 'database_cleaner'
  gem 'fakeweb', '~> 1.3'
  gem 'rack-test'

  gem 'factory_girl', '~> 1.3'

  gem 'growl'

  gem 'guard', '~> 0.3'
  gem 'guard-bundler'
  gem 'guard-pow'
  gem 'guard-rspec'
end

group :production do
  gem 'thin', '~> 1.2'
end
