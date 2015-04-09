require 'thor'
require 'redditsherpa/client'
require 'launchy'
require 'rainbow/ext/string'
require 'pry'

module Redditsherpa
  class CLI < Thor
    include Launchy

    desc "search TOPIC", "Search for content on reddit by passing in a topic"
    def search(topic)
      response = client.search(topic)
      result = response[:data][:children]
      puts "***********************************"
      puts ("Search Results:").color(:magenta).underline.bright
      result.each_with_index do |hash, i|
        unless i == 0
          puts Rainbow(hash[:data][:title]).bright
          puts (hash[:data][:description])
          puts "_____________________________________________"
        end
      end
    end

    desc "read SUBREDDIT", "Get the top posts from a given subreddit"
    def read(subreddit)
      puts "reading subreddit..."
      response = client.get_posts(subreddit)
      posts = response[:data][:children]
      i = 1
      @array = []
      posts.take(25).each do |post|
        post = post[:data]
        post_id = post[:id]
        @array << "http://www.reddit.com/r/#{subreddit}/comments/#{post_id}/"
        puts ("#{i}. " + post[:title]).bright
        puts "#{post[:url]}"
        puts "____________________________________________________________"
        puts ("Upvotes: #{post[:ups]}").color(:green) + "|" + Rainbow("Downvotes: #{post[:downs]}").color(:red) + "| Number of Comments #{post[:num_comments]}"
        puts
        i += 1
      end

      puts "To open a page, please enter a topic number after 'open'. Example: open 12"
      puts "To open the comments for a specific topic in terminal, enter 'c' and then the topic number. Example: c 12"

      input = STDIN.gets.chomp!
      if input.include?("open")
        input = input.gsub("open ","")
        target_url = @array[input.to_i - 1]
        puts "Opening #{target_url}..."
        Launchy.open(target_url)
      else
        input.include?("c")
        input = input.gsub("c ","")
        comments_url = @array[input.to_i - 1] +".json"

        response2 = Faraday.get comments_url
        json_response2 = JSON.parse(response2.body)

        thread = json_response2[0]["data"]["children"][0]
        puts
        puts "***************************COMMENTS***************************"
        puts
        puts "______________________________________________________________"
        puts Rainbow("Title: #{thread["data"]["title"]}").magenta.bright
        puts "Author: #{thread["data"]["author"]}"
        puts "Number of Comments: #{thread["data"]["num_comments"]}"
        puts "______________________________________________________________"

        top_level_comments = json_response2[1]["data"]["children"]
        top_level_comments.each do |comment|
          print_subcomments_recursively(comment)
        end
      end
    end

    private

    def client
      @client ||= Redditsherpa::Client.new
    end

    def print_subcomments_recursively(comment, depth=0)
      puts "\t"*depth + Rainbow("Level #{depth}: ").bright + "#{comment["data"]["body"]} -- by #{comment["data"]["author"]}\n\n"
      if comment["data"]["replies"] == "" or !comment["data"].has_key?("replies")
        puts "-------------------------END THREAD-------------------------\n"
      else
        sub_comments = comment["data"]["replies"]["data"]["children"]
        sub_comments.each do |comment|
          print_subcomments_recursively(comment, depth + 1)
        end
      end
    end
  end
end
