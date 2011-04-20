require 'factory_girl'

Factory.define :repository do |f|
  f.sequence(:owner) { |n| "owner#{n}" }
  f.sequence(:name)  { |n| "repo#{n}" }
  f.url "https://github.com/tsigo/gemphile"
end

Factory.define :gem_entry, :parent => :repository do |f|
  f.after_create do |repo|
    repo.gems.create(name: "#{repo.name}-gem")
    repo.save # Gets GemCount to update
  end
end
