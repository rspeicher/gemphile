guard 'bundler' do
  watch('Gemfile')
end

guard 'pow' do
  watch('.powrc')
  watch('.powenv')
  watch('.rvmrc')
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('app/app.rb')
  watch(%r{app/helpers})
  watch(%r{app/views})
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
