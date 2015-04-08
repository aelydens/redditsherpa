require 'thor'
require 'redditsherpa/client'
require 'pry'

module Redditsherpa
  class CLI < Thor
    desc "search", "Search for content on reddit by passing in a topic"

    def search( topic )
      result = client.search( topic )

      puts result
    end

    desc "read SUBREDDIT", "Get the top posts from a given subreddit"

    def read( subreddit )
      puts "reading subreddit..."
      response = client.get_posts( subreddit )
      posts = response[:data][:children]

      i = 1
      array = []
      posts.take(25).each do |post|
        post = post[:data]
        post_id = post[:id]
        array << post_id
        puts "#{i}. " + post[:title]
        puts "http://www.reddit.com/r/#{subr}/comments/#{post_id}/.json"
        puts "#{post["url"]}"
        puts "____________________________________________________________"
        puts "Upvotes: #{post[:ups]} | Downvotes: #{post[:downs]} | Number of Comments #{post[:num_comments]}"
        puts ""
        i += 1
      end
    end

    private

    def client
      @client ||= Redditsherpa::Client.new
    end
  end
end
