require 'thor'
require 'redditsherpa/client'
require 'pry'


module Redditsherpa
  class CLI < Thor

    # prompt_for_input(true) # welcome to Annie's app, here are your input options:
    #
    # # Run loop (infinite)
    # loop do
    #   input = gets.chomp
    #
    #   if input == 'comments'
    #     search(input)
    #   elsif input == '--exit'
    #     System.exit
    #   end
    #   # code here that handles that user input, calling the methods you've defined
    #
    #   prompt_for_input
    #   # re-prompt giving them options for what to do next
    # end

    # desc "search", "Search for content on reddit by passing in a topic"
    # def search(topic)
    #   response = client.search(topic)
    #   binding.pry
    # end

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
        @array << "http://www.reddit.com/r/#{subreddit}/comments/#{post_id}/.json"
        puts "#{i}. " + post[:title]
        puts "#{post[:url]}"
        puts "____________________________________________________________"
        puts "Upvotes: #{post[:ups]} | Downvotes: #{post[:downs]} | Number of Comments #{post[:num_comments]}"
        puts ""
        i += 1
      end
      puts "To see comments for a particular topic, run comments TOPICNUMBER.\nEx. To see all comments for topic 12, run 'comments 12'\n\n"
      prompt_for_next_input # puts "To exit use CTRL + C, otherwise type --help to see which commands you can run"
    end

    desc "comments TOPICNUMBER", "Get the comments for a specific topic thread"
    def comments(topicnumber)
      target_url = @array[topicnumber.to_i - 1]
      response = Faraday.get target_url
      json_response = JSON.parse(response.body)

      thread = json_response[0]["data"]["children"][0]
      puts "______________________________________________________________"
      puts "Title: #{thread["data"]["title"]}"
      puts "Author: #{thread["data"]["author"]}"
      puts "Number of Comments: #{thread["data"]["num_comments"]}"
      puts "to open in reddit, use flag --open"
      puts "______________________________________________________________"

      recursive_child_output(json_response[1]["data"]["children"])
    end

    private

    def client
      @client ||= Redditsherpa::Client.new
    end

    def recursive_child_output(children, depth=0)
      children.each do |child|
        if child["data"]["replies"] == ""
          puts "--END THREAD--"
        else
          child["data"]["replies"]["data"]["children"].each do |child|
            puts
            puts "\t"*depth + "Level #{depth}: #{child["data"]["body"]} -- by #{child["data"]["author"]}"

            unless child["data"] == nil || child["data"]["replies"]["data"] == nil
              recursive_child_output(child["data"]["replies"]["data"]["children"], depth + 1)
            end
          end
        end
      end
    end

  end
end

while true do
  # app code goes in here
  # System.exit
end
