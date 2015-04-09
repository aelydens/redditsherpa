require 'redditsherpa/client'
require 'launchy'
require 'rainbow/ext/string'

module Redditsherpa
  class CLI
    include Launchy

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
      puts ("Search for something else or read a subreddit! Type 'read SUBREDDIT' with a specific subreddit or 'surprise me' for a random subreddit. Or type help for more.").color(:cyan)
    end

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
      puts ("To look at comments for a specific topic in the console, type 'comments TOPICNUMBER'. Ex. 'comments 25'").color(:cyan)
      puts ("To open a link in the browser, type 'open TOPICNUMBER'. Ex. 'open 12'").color(:cyan)
      puts ("Done browsing? Type 'exit' or 'x' to quit redditsherpa").color(:cyan)
    end

    def comments(topicnumber)
      comments_url = @array[topicnumber.to_i - 1] +".json"
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
      puts ("Read another subreddit! Type 'read SUBREDDIT' with a specific subreddit or 'surprise me' for a random subreddit.").color(:cyan)
    end

    def open_up(topicnumber)
      target_url = @array[topicnumber.to_i - 1]
      puts "Opening #{target_url}..."
      Launchy.open(target_url)
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

#loop
cli = Redditsherpa::CLI.new

puts "Redditsherpa"
puts "*"*50
puts "If you ever get lost, type help to see a list of commands."

while true
    begin
      input = STDIN.gets.chomp
      if input == 'help'
        puts ("Useful redditsherpa commands").color(:cyan)
        puts ("-" * 20).color(:cyan)
        puts ("search WORD - search reddit for stuff").color(:cyan)
        puts ("read SUBREDDIT - read a specific subreddit").color(:cyan)
        puts ("x or exit - quit redditsherpa").color(:cyan)
        puts ("surprise me - read a randomly selected subreddit").color(:cyan)
        puts "-" * 20

      elsif input.include?('search')
        topic = input.gsub('search ', '').strip
        cli.search(topic)

      elsif input.include?('read')
        subreddit = input.gsub('read ', '').strip
        cli.read(subreddit)

      elsif input.include?('comments')
        topicnumber = input.gsub('comments ', '').strip
        cli.comments(topicnumber)

      elsif input == 'surprise me'
        subreddits = ["funny", "AdviceAnimals", "todayilearned", "WTF", "leagueoflegends", "aww", "AskReddit", "mildlyinteresting"]
        subreddit = subreddits.sample
        cli.read(subreddit)

      elsif input.include?('open')
        topicnumber = input.gsub('open ', '').strip
        cli.open_up(topicnumber)

      elsif input == 'x' || input == 'exit'
        exit
      else
        puts ("Your command is not recognized. Please type help to see a list of approved commands.").color(:red)
      end
    rescue
      puts "
............................................. . . ... . .      .    .  .    ....
........................................... .     ...     .    .  .  . .    ..
..........................................$Z+.   .... ?ZZZZZZ, .  .... .    ..
......YOU DONE MESSED UP................ $ZZZZZZZZZ+.ZZZ. .,ZZ?. ..... .  .. . .
.......  . .. .... .  . .......... ......ZZ .. .,IZZZZZ   . .ZZ. ..... .. . .. .
.Type help to see a list of accepted ...7Z$ ........=ZZ  ....ZZ.................
.....  commands!!!!       .             ZZ..... .... ZZ7 .. ZZ7 ................
...                                    $Z$ ...........$ZZZZZZ+  ................
. ...Stop breaking shit.                 ZZ  .............,==.... .... .........
                                      7ZZ  .................... ................
. .  .   .                   $ZZZZZZZZZZ$ZI:. ..................................
...                   ZZZI$ZZZZ=ZZZZZZZZZZZZZZZZZ~..............................
.............  +ZZ=  :ZZZZZZ,77.  .=..  . ..   7ZZZZZ+. . ,IZ7, ................
..... . .  .:ZZZZZZZZZZ$7=...77...?7$.... .........+ZZZZ$ZZZZZZZ$ ..............
..... . .  $ZZ. ,ZZZZZ.:777.=77I.I77,.... ............+ZZZ,....$ZZ..............
.....     .ZZ   ?ZZ..   $77777777777....+ ..............,ZZZ....+ZZ.............
....... ..+ZZ  :ZZ.777=..7777777777..+777+....... ........+ZZ:...ZZ ............
.........  ZZ.ZZZ  .77777777777777777777.....77777.........,ZZ,.=ZZ ............
..... . ...ZZZZZ     .I777777777777777......7777777.........:ZZIZZ..............
........... $ZZZ.  .  ..777777777777,.......7777777......... $ZZZ,..............
..... ..  .. ZZI ...:7$7777777777777$77.....777777I..........=ZZ ...............
..... . .  . ZZ: ..7777777777777777777777?...~777............,ZZ................
.....      . ?ZZ   .     ..I7777$.. .........................+Z$................
.......... . .ZZ          ..777I... ... .....................ZZ:................
.......... . .$ZZ         ..777.... ........................$Z$.................
.....      .  .ZZ$       ...777.... .....=: ...............7ZZ .................
..... . .. .    7ZZ.      ..77..   IZZZZZZZZZZ$ ......... OZ$...................
............  .. ~ZZO... .....+ZZZZZZ.,$ZZ ..$ZZ...  . ,ZZZ,    . .. . ..... ..
... ........ ... . $ZZZ.......ZZ .$ZZ ...... .  .... =ZZZ?    . . .. . ..... ...
............   . .   .ZZZZZ  $Z$...ZZ............,ZZZZZ.  .     ...... . ......
.......................:ZZZZZZZZ~.  ?     ..~$ZZZZZ$~. .          .    . .
. . ....................=ZZZ.~ZZZZZZZZZZZZZZZZZ= ZZZZ  .          .
...................... ZZZZZ............... .    ZZ+ZZ$.          .      .   .
......................ZZ7:ZZ................... .IZI OZZ. .  .  .... . .........
...  .......   . . . ZZI =ZZ.... .. . ..... .   .+ZZ .ZZ~         .      .
............ . . ....ZZ .IZI....... . ......... .+ZZ . ZZ    .  .... ..........
....................7ZI .IZI................    .+ZZ . ZZ,        .. .   ... .
...  ...............ZZ:..+ZZ............... .    +ZZ . ZZ.        .    . .
... ................ZZ+..:ZZ................... .$Z? . ZZ.      . ..   . ......
....................~Z$ . ZZ.................   .ZZ: . ZZ         ..       .
. .  .... ..     ... ZZ...ZZ...............      ZZ  .ZZ7         .  .
......................ZZ..ZZ:..............      ZZ .$ZZ.         .
.............  . .   .=ZZ~IZZ...... ............?ZZ.ZZZ.  . .  ....... . ......
...  ....... . . .   .  ZZZZZ ..... ....... ... ZZZZZ7 .        . .. . . ... .
.............  ... . .   .$$Z+.. .... ... .....,ZZZI.. . . . .  . .. . ........
........................... ZZ ................ZZ:.  ...     .  . .. ...........
. .        .              . $ZZ. .    . . .   7ZZ .  . .          .
..... ... .. . . .      7ZZZZZZ= .. ..........ZZZZZZ$. .     .  . .. . . ......
............  .. .. . ZZZZ... ZZ... ........ ZZ,...ZZZZ. .      . .. ..........
..... . .  .   . ..  $ZZ  .  . ZZ7.   . . .=ZZ. .....IZZ.  . .  . .. . ..... ..
............   . .  .ZZ.........ZZZ...... ZZO.        ZZ.       . .. .   ... ..
...   ... ..   . .. .ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ........................"
  end
end
