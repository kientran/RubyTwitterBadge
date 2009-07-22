# Author::    Kien Tran(mailto:kientran@kientran.com)
# Copyright:: Copyright (c) 2009
# License::   MIT 
# Date:: June 12, 2009
#
# This module generates a unordered list of tweets pulled from the Cacher

require 'yajl'              # JSON Parser
require 'TwitterCacher.rb'  # Twitter Cacher

def twitterBadge( userName, userPassword, count=4 )

    # Create the twitter Cacher object to pull feed
    # Password is needed in case feed is protected
    # HTTP Basic Auth hasn't been deprecated...yet...so...lazy wins for now
 
    tc = TwitterCacher.new(userName, userPassword, "Mozilla/5.0 (compatible; TwitterCacher/1.0; +http:#www.kientran.com)") 
    # Create a timeline object of the feed (pull from live if old)
    tweets = Yajl::Parser.new.parse(tc.getUserTimeline)

    tweetList = ''
    # create unordered list of tweets
    tweetList += '<ul>'

    tweets.each do |tweet|
        
        text = tweet[:text].to_s
        # Format date as 5 min ago, 2 hours ago, etc.
        date = tweet[:created_at].to_s

        # Generate direct link to tweet
        tweetid = tweet[:id].to_s
        screenname = tweet[:user][:screen_name].to_s
        tweetLink = 'http://twitter.com/' + screenname + '/status/' + tweetid

        # Turn links into links
        text = text.gsub( /(((f|ht){1}tp:\/\/)[-a-zA-Z0-9@:%_\\+.~#?&\/\/=]+)/, 
                %Q{<a href="\\1" target="_blank">\\1</a>} )
        # Turn twitter @username into links to the users Twitter page
        text = text.gsub( /(^|\s)@(\w+)/, 
                %Q{\\1<a href='http://www.twitter.com/\\2'>@\\2</a>} ) 
        # Turn #hashtags into searches
        text = text.gsub( /(^|\s)#(\w+)/, 
                %Q{\\1<a href='http://search.twitter.com/search?q=%23\\2'>#\\2</a>} ) 
 

        # Personal Formatting
        # <li>Tweet Text <span>(<a href="linktotweet">some time ago</a>)<span></li>
        tweetList += "<li>#{text} <span>(<a href='#{tweetLink}'>#{date}</a>)</span></li>"
    end

    tweetList += "</ul>"
    # Returns the stack of li's enclosed by ul
    return tweetList

end
