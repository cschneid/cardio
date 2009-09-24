require 'net/http'
require 'uri'
require 'contest'

module Cardio
  module Assertions
    def assert_gzipped(res)
      assert_header res, "Content-Encoding", "gzip"
    end

    ## TODO parse the XML and validate
    def assert_valid_xml(res)
      assert_content_type res, "application/xml" 
    end

    def assert_html(res)
      assert_content_type res, "text/html"
      assert_content res, "<html>"
    end

    def assert_css(res)
      assert_content_type res, "text/css"
    end

    # TODO: Wishlist
    #def assert_valid_html
    #end

    # TODO: Wishlist
    #def assert_valid_css
    #end

    def assert_redirect(res, location)
      assert_in_array ["301", "302", "303", "307"], res.code
      assert_header res, "Location", location
    end

    def assert_code(res, code)
      assert_equal code.to_s, res.code
    end

    def assert_in_array(array, item)
      if ! array.include? item
        flunk build_message("", 'One of <?> was expected, but got <?> ', [302,303,307].inspect, item)
      end
    end

    def assert_content(res, content)
      assert_match /#{content}/, res.body
    end

    ## TODO: Make sure that JSON.parse raises an error
    def assert_valid_json(res)
      require 'json'
      assert_content_type res, "application/json"
      begin
        JSON.parse(res.body)
      rescue JSON::ParserError => e
        flunk build_message("", "String <?> is not valid JSON.  The Parser Error was: #{e.message}", res.body)
      end
    end

    def assert_etag(res)
      assert_header_present res, "ETag"
    end

    ## TODO: Make this much smarter to check types and duration of caches
    def assert_cached(res, value=nil)
      if value
        assert_header res, "Cache-Control", value
      else
        assert_header_present res, "Cache-Control"
      end
    end

    def assert_header_present(res, header)
      assert (! res[header].nil?)
    end

    def assert_header(res, header, value)
      assert_equal value, res[header]
    end

    ## TODO
    #def assert_basic_auth
    #end

    def assert_content_type(res, content_type)
      assert_header res, "Content-Type", content_type
    end
    
    ##
    # TODO: Use the headers argument
    #
    # Use Net::HTTP to get a url and associated headers. Cache the result, 
    # and return the cached version if it is present.
    # Every individual test run will re-fetch all URLs 
    #
    # 
    # (ie, cache is cleared each test)
    # @param [String] The URL to fetch. If this has been fetched previously for this test, it will not be refetched
    # @return The Net::HTTP response object
    def fetch(url, headers={})
      @url_cache ||= Hash.new
      return @url_cache[url] if @url_cache.has_key?(url)

      uri = URI.parse(url)

      path = uri.path == "" ? "/" : uri.path

      req = Net::HTTP::Get.new(path)
      res = Net::HTTP.start(uri.host, uri.port) {|http|
        http.request(req)
      }

      @url_cache[url] = res
      
      return res
    end
  end  
end
