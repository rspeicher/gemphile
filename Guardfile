guard 'bundler' do
  watch('Gemfile')
end

guard 'pow' do
  watch('.powrc')
  watch('.powenv')
  watch('.rvmrc')
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('app.rb')
end

guard 'rspec', :cli => '--format documentation' do
  watch('gemphile.rb')         { 'spec/gemphile_spec.rb' }
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^models/(.+)\.rb})  { |m| "spec/models/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
  watch(%r{^spec/fixtures/})   { "spec" }

  watch('spec/spec_helper.rb')                       { "spec" }
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
end
