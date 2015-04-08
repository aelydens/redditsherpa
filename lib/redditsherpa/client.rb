# require 'httparty'
#
# module Redditsherpa
#   class Client
#     include Faraday
#     base_uri "http://www.reddit.com/"
#
#     def get_posts( subreddit )
#       self.class.get "r/#{subreddit}/.json"
#     end
#
#
#
#
#
#
#     # def get_comments( subreddit )
#     #   self.class.get "r/#{subreddit}/.json"
#     #
#     #
#     #   self.class.get "r/#{subreddit}/comments/#{key}/.json"
#     # end
#
#   end
# end
#
# require 'httparty'
#
# module Redditsherpa
#   class Client
#     include HTTParty
#     base_uri "http://www.reddit.com/"
#
#     def get_posts( subreddit )
#       self.class.get "r/#{subreddit}/.json"
#     end
#
#     def get_comments( subreddit )
#       self.class.get "r/#{subreddit}/.json"
#       get key
#
#       self.class.get "r/#{subreddit}/comments/#{key}/.json"
#     end
#
#     def search( query )
#       params = { 'q' => query }
#       self.class.get "subreddits/search/.json", params
#     end
#   end
# end

# response = Faraday.new(:url => 'http://www.reddit.com/').get do |req|
#   req.url "r/#{subreddit}/.json"
#   req.headers['Content-Type'] = 'application/json'
#   req.headers['X-TrackerToken'] = token
# end

require 'faraday'
require 'pry'

module Redditsherpa
  class Client
    include Faraday
    def initialize
      @conn = Faraday.new(:url => 'http://www.reddit.com/')
    end

    def search( query )
      params = { 'q' => query }
      response = @conn.get "subreddits/search/.json", params
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
