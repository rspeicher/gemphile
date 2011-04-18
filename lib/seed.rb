require_relative '../app/libraries'

URL = "http://github.com/api/v2/json/repos/show/%s"

repos = %w(
  aslakhellesoy/cucumber
  defunkt/github-gem
  defunkt/hurl
  defunkt/resque
  github/albino
  github/github-services
  github/gollum
  justinfrench/formtastic
  plataformatec/capybara-zombie
  plataformatec/devise
  plataformatec/devise_example
  plataformatec/has_scope
  plataformatec/hermes
  plataformatec/responders
  plataformatec/show_for
  plataformatec/simple_form
  rails/rails
  thoughtbot/appraisal
  thoughtbot/capybara-webkit
  thoughtbot/clearance
  thoughtbot/copycopter_client
  thoughtbot/dddd
  thoughtbot/diesel
  thoughtbot/factory_girl
  thoughtbot/factory_girl_rails
  thoughtbot/fistface
  thoughtbot/high_voltage
  thoughtbot/pacecar
  thoughtbot/paperclip
  thoughtbot/shoulda
  thoughtbot/shoulda-context
  thoughtbot/shoulda-matchers
  thoughtbot/shoutbox
  thoughtbot/trout
)

repos.each do |repo|
  repo.strip!
  puts repo

  c = Curl::Easy.perform(URL % repo)
  Repository.from_payload(c.body_str)
end
