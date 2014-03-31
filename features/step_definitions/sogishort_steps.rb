require_relative '../../lib/url'

When(/^I short the url "(.*?)"$/) do |url|
  @hash = Url.to_hash url
end

Then(/^the hash of the short url is "([^"]*)"$/) do |hash|
  expect(@hash).to eql(hash)
end
