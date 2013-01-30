require 'sinatra'
require 'net/http'
require 'open-uri'
require 'iron_cache'
require 'digest/md5'

get '/*' do
  content_type "application/json"
  
  api_request_path = params[:splat].join('/')

  cache_key = Digest::MD5.hexdigest(api_request_path)

  @client = IronCache::Client.new
  @cache = @client.cache("wu_api_proxy")

  cache_response = @cache.get(cache_key)
  
  if cache_response != nil
    return cache_response.value
  end

  response = open(ENV['API_HOST']+ENV['API_BASE_URI']+"/"+ENV['API_KEY']+"/"+api_request_path).read
  puts api_request_path
  @cache.put(cache_key, response, :expires_in=>600)

  response
end
