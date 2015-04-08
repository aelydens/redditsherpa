require 'faraday'
require 'json'

module Redditsherpa
  class Client
    include Faraday
    def initialize
      @conn = Faraday.new(:url => 'http://www.reddit.com/')
    end

    def search( query )
      params = { 'q' => query }
      response = @conn.get "subreddits/search/.json", params
      JSON.parse(response.body, symbolize_names: true)
    end

    def get_posts(subreddit)
      response = @conn.get do |req|
        req.url "r/#{subreddit}/.json"
        req.headers['Content-Type'] = 'application/json'
      end
      JSON.parse(response.body, symbolize_names: true)
    end

  end
end
