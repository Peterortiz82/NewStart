AngellistApi.configure do |config|
  config.access_token = ENV["angel_key"]
end

Rubillow.configure do |config|
  config.zwsid = ENV["zillow_token"]
end
