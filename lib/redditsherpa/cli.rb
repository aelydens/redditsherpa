require 'thor'
require 'redditsherpa/client'
require 'launchy'
require 'pry'

module Redditsherpa
  class CLI < Thor
    include Launchy

    loop do
      input = gets.chomp

      if input == 'comments'
        search(input)
      elsif input == '--exit'
        System.exit
      end
      # code here that handles that user input, calling the methods you've defined

      prompt_for_input
      # re-prompt giving them options for what to do next
    end

    def prompt_for_input

    desc "search TOPIC", "Search for content on reddit by passing in a topic"
    def search(topic)
      response = client.search(topic)
      result = response[:data][:children]
      result.each_with_index do |hash, i|
        unless i == 0
          puts hash[:data][:title]
          puts hash[:data][:description]
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
        puts "#{i}. " + post[:title]
        puts "#{post[:url]}"
        puts "____________________________________________________________"
        puts "Upvotes: #{post[:ups]} | Downvotes: #{post[:downs]} | Number of Comments #{post[:num_comments]}"
        puts ""
        i += 1
      end
      puts "To open a page, please enter a topic number after 'open'. Example: open 12"
      puts "To open the comments for a specific topic in terminal, enter 'c' and then the topic number. Example: c 12"

      input = STDIN.gets.chomp!
      if input.include?("open")
        input = input.gsub("open ","")
        target_url = @array[input.to_i]
        puts "Opening #{target_url}..."
        Launchy.open(target_url)
      else
        input.include?("c")
        input = input.gsub("c ","")
        puts input
        puts @array[input.to_i]+".json"
        comments_url = @array[input.to_i] +".json"

        response2 = Faraday.get comments_url
        json_response2 = JSON.parse(response2.body)

        thread = json_response2[0]["data"]["children"][0]
        puts
        puts
        puts "______________________________________________________________"
        puts "Title: #{thread["data"]["title"]}"
        puts "Author: #{thread["data"]["author"]}"
        puts "Number of Comments: #{thread["data"]["num_comments"]}"
        puts "______________________________________________________________"

        recursive_child_output(json_response2[1]["data"]["children"])
      end
      # puts "To see comments for a particular topic, run comments TOPICNUMBER.\nEx. To see all comments for topic 12, run 'comments 12'\n\n"
      # prompt_for_next_input # puts "To exit use CTRL + C, otherwise type --help to see which commands you can run"
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

# while true do
#   # app code goes in here
#   # System.exit
# end
