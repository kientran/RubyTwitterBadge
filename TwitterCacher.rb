require 'curb'

# Author::    Kien Tran(mailto:kientran@kientran.com)
# Copyright:: Copyright (c) 2009
# License::   MIT 
# Date:: June 12, 2009

# This class allows for cached reading of a Twitter timeline 
# It will refresh from the twitter API when the cached file is sufficently
# aged

class TwitterCacher
    attr_accessor :userAgent

    # Refresh is time in seconds, default is 30 minutes
    def initialize( username = nil, password = nil, userAgent = nil, refresh = 1800, type = "json")

        if( ( username.nil? or password.nil? ) or ( username.empty? or password.empty? ))
            raise "Username or Password cannot be empty"
        end

        if( userAgent.nil? or userAgent.empty? )
            raise "UserAgent cannot be empty" 
        end
 
        @username = username
        @password = password
        @type = type
        @userAgent = userAgent 
        @cacheFile = @username + '.twitter.' + @type
        @refresh = refresh
    end

    def setUserAgent( userAgent = nil )
        if( userAgent.nil? or userAgent.empty? )
            raise "UserAgent cannot be empty" 
        end
        @userAgent = userAgent
    end

    def getUserTimeline( count = 6 )
        
        last = getCacheLastModified()
        now = Time.now

        # If the cache file doesn't exist, or if the last time the cache
        # was refreshed is greater than the refresh time, get a new update
        if ( (not last) or ( (now - last) > @refresh ) )
            # Load new content from twitter
            timeline = loadAndSave( count )
        else
            # Return cache file
            timeline = readCache  
        end

        if ( timeline === false )
            raise "TwitterCacher was unable to retrieve timeline.  Please check check user credentials and delete the cache file."
        end

        return timeline
    end

    def readCache
       
        if (not File::exists?(@cacheFile))
            return false
        end

        cacheData = ''

        begin
            file = File.open(@cacheFile, 'r')
            file.each_line do |line|
                cacheData += line
            end
        rescue
            return false
        ensure
            file.close
        end

        return cacheData
    
    end

    def saveCache( data )
    
        begin 
          file = File.open(@cacheFile, 'w')
          file.write(data)
          file.close
        rescue
            return false
        end
    end

    def getCacheLastModified
        if not File::exists?(@cacheFile)
            return false
        end
        return File::mtime(@cacheFile)
    end

    def loadURL( url )
        c = Curl::Easy.new(url) do |curl|
            curl.userpwd = @username + ':' + @password
            curl.perform
        end
        if c.response_code == 200
            return c.body_str
        else
            return false
        end

    end

    def loadUserTimeline( count = 6 )
        request = 'http://twitter.com/statuses/user_timeline.' + @type + '?count=' + count.to_s
        return loadURL(request)

    end

    def loadAndSave( count = 6 )
 
        data = loadUserTimeline( count )
        
        if (data === false)
            return false
        else 
            saveCache( data )
            return data
        end 
    end

end
