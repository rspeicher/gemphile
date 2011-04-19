group 'backend' do
  guard 'bundler' do
    watch('Gemfile')
  end

  guard 'rspec', :cli => '-d --format documentation' do
    watch('app/app.rb')             { 'spec/app/app_spec.rb' }
    watch(%r{^spec/.+_spec\.rb})
    watch(%r{^app/models/(.+)\.rb}) { |m| "spec/app/models" }
    watch(%r{^lib/(.+)\.rb})        { |m| "spec/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')    { "spec" }
    watch(%r{^spec/fixtures/})      { "spec" }

    watch('spec/spec_helper.rb')    { "spec" }
    watch('spec/factories.rb')      { "spec" }
    watch(%r{^spec/.+_spec\.rb})
    watch(%r{^lib/(.+)\.rb})        { |m| "spec/lib/#{m[1]}_spec.rb" }
  end
end

group 'frontend' do
  guard 'compass' do
    watch(%r{^app/stylesheets/(.*)\.s[ac]ss})
  end

  guard 'livereload' do
    watch(%r{app/views/.*})
    watch(%r{app/templates/.*})
    # watch(%r{public/css/.*}) # Doesn't seem to work with compass
  end

  guard 'pow' do
    watch('.powrc')
    watch('.powenv')
    watch('.rvmrc')
    watch('Gemfile')
    watch('Gemfile.lock')
    watch('app/app.rb')
    watch(%r{^app/views/.*})
  end
end
