source :gemcutter

group :development, :test do
  gem 'rspec', '~> 2.5'
end

gem 'guard', :group => :test

group :test do
  gem 'cucumber', '~> 0.10'
  gem 'cucumber-rails', '>= 0.4'
end
