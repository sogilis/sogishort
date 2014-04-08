require_relative '../../lib/gitkvstore'



Given(/^a key "([^"]*)"$/) do |key|
  @key = key
end

And(/^a value "([^"]*)"$/) do |value|
  @value = value
end

When(/^store the value under the key$/) do
  ENV['REPO_PATH'] = 'links_test.git'
  @store = GitKVStore.new
  @store.set @key, @value
end

Then(/^the value under "([^"]*)" is "([^"]*)"$/) do |key, value|
  expect(@store.get(key)).to eql(value)
end