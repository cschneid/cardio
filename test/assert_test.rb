require File.dirname(__FILE__) + '/test_helper'

class MockResponse
  def initialize; @headers = Hash.new; end
  def [](thing)
    return @headers[thing]
  end
  def []=(thing, value)
    @headers[thing] = value
  end
  attr_accessor :code, :body
end

class AssertTest < Test::Unit::TestCase
  context "assert_in_array" do
    test "assert_in_array raises the correct error" do
      assert_raises Test::Unit::AssertionFailedError do
        assert_in_array [1,2], 3 
      end
    end

    test "assert_in_array passes when given a valid test" do
      assert_in_array [1,2,3], 3
    end
  end

  context "assert_gzipped" do
    test "should return true if the header is set right" do
      res = MockResponse.new
      res["Content-Encoding"] = "gzip"
      assert_gzipped(res)
    end
    test "should fail if the header is set wrong" do
      res = MockResponse.new
      res["Content-Encoding"] = "text"
      assert_raises Test::Unit::AssertionFailedError do
        assert_gzipped(res)
      end
    end
    test "should fail if the header is not set" do
      res = MockResponse.new
      assert_raises Test::Unit::AssertionFailedError do
        assert_gzipped(res)
      end
    end
  end

  context "assert_html" do
    test "passes on a valid HTML page" do
      res = MockResponse.new
      res.body = <<-EOF
        <html>
          <head>
            <title>TestPage</title>
          </head>
          <body><h1>Stuff Here</h1></body>
        </html>
      EOF
      res["Content-Type"] = "text/html"
      assert_html res
    end
    test "fails on a non-html body" do
      res = MockResponse.new
      res.body = "This is not html. This is just a string"
      assert_raises Test::Unit::AssertionFailedError do
        assert_html res
      end
    end
  end

  context "assert_css" do
    test "passes on a valid CSS body" do
      res = MockResponse.new
      res.body = <<-EOF
        #wrapper {
          background-color: red;
        }
      EOF
      res["Content-Type"] = "text/css"
      assert_css res
    end
    test "fails on a non-css content" do
      res = MockResponse.new
      res.body = "This is not css. And has a wrong content-type"
      assert_raises Test::Unit::AssertionFailedError do
        assert_css res
      end
    end
  end

  context "assert_redirect" do
    test "passes on right code and location" do
      res = MockResponse.new
      res.code = "301"
      res["Location"] = "http://foobar.com"
      assert_redirect(res, "http://foobar.com")
    end
    test "fails on wrong code" do
      res = MockResponse.new
      res.code = "200"
      res["Location"] = "http://foobar.com"
      assert_raises Test::Unit::AssertionFailedError do
        assert_redirect(res, "http://foobar.com")
      end
    end
    test "fails on wrong location" do
      res = MockResponse.new
      res.code = "301"
      res["Location"] = "http://baz.com"
      assert_raises Test::Unit::AssertionFailedError do
        assert_redirect(res, "http://foobar.com")
      end
    end
  end

  context "assert_code" do
    test "passes on a matching code" do
      res = MockResponse.new
      res.code = "301"
      assert_code res, 301
    end
    test "handles both string and fixnum" do
      res = MockResponse.new
      res.code = "301"
      assert_code res, 301
      assert_code res, "301"
    end
    test "fails on mismatched code" do
      res = MockResponse.new
      res.code = "301"
      assert_raises Test::Unit::AssertionFailedError do
        assert_code res, 200
      end
    end
  end

  context "assert_content" do
    test "passes on a contained string" do
      res = MockResponse.new
      res.body = "this <b>is html</b> text"
      assert_content res, "html"
    end
    test "fails on a missing string" do
      res = MockResponse.new
      res.body = "this <b>is html</b> text"
      assert_raises Test::Unit::AssertionFailedError do
        assert_content res, "not there"
      end
    end
  end

  context "assert_valid_json" do
    test "passes on a valid JSON string" do
      res = MockResponse.new
      res.body = '["foo", "bar", "baz"]'
      res["Content-Type"] = "application/json"
      assert_valid_json res
    end
    test "fails on an invalid json string" do
      res = MockResponse.new
      res.body = "this <b>is html</b> text"
      res["Content-Type"] = "application/json"
      assert_raises Test::Unit::AssertionFailedError do
        assert_valid_json res
      end
    end
    test "fails on an incorrect content type" do
      res = MockResponse.new
      res.body = '["foo", "bar", "baz"]'
      res["Content-Type"] = "application/not-json"
      assert_raises Test::Unit::AssertionFailedError do
        assert_valid_json res
      end
    end
  end

  context "assert_etag" do
    test "passes on a etag header present" do
      res = MockResponse.new
      res["ETag"] = "FFFFFFF"
      assert_etag res
    end
    test "fails on a missing etag header" do
      res = MockResponse.new
      assert_raises Test::Unit::AssertionFailedError do
        assert_etag res
      end
    end
  end

  context "assert_cached" do
    test "passes if cache header is set" do
      res = MockResponse.new
      res["Cache-Control"] = "Foobar"
      assert_cached res
    end
    test "passes if the cache header is set to the correct value, and the value is specified" do
      res = MockResponse.new
      res["Cache-Control"] = "Foobar"
      assert_cached res, "Foobar"
    end
    test "fails if cache header is not set" do
      res = MockResponse.new
      assert_raises Test::Unit::AssertionFailedError do
        assert_cached res
      end
    end
    test "fails if the cache header is set to the wrong value, and the value is specified" do
      res = MockResponse.new
      res["Cache-Control"] = "Foobar"
      assert_raises Test::Unit::AssertionFailedError do
        assert_cached res, "Baz"
      end
    end
  end

  context "assert_header_present" do
    test "passes with the header present" do
      res = MockResponse.new
      res["TestHeader"] = "Foobar"
      assert_header_present res, "TestHeader"
    end
    test "fails with the header missing" do
      res = MockResponse.new
      assert_raises Test::Unit::AssertionFailedError do
        assert_header_present res, "TestHeader"
      end
    end
  end

  context "assert_header" do
    test "matches headers right" do
      res = MockResponse.new
      res["TestHeader"] = "Foobar"
      assert_header res, "TestHeader", "Foobar"
    end
    test "fails on wrong header value" do
      res = MockResponse.new
      res["TestHeader"] = "Foobar"
      assert_raises Test::Unit::AssertionFailedError do
        assert_header res, "TestHeader", "Baz"
      end
    end
    test "fails with a nil header" do
      res = MockResponse.new
      assert_raises Test::Unit::AssertionFailedError do
        assert_header res, "TestHeader", "Baz"
      end
    end
  end

  context "assert_content_type" do
    test "passes with the right content type" do
      res = MockResponse.new
      res["Content-Type"] = "text/plain"
      assert_content_type res, "text/plain"
    end
    test "fails with the wrong content type" do
      res = MockResponse.new
      res["Content-Type"] = "text/plain"
      assert_raises Test::Unit::AssertionFailedError do
        assert_content_type res, "text/html"
      end
    end
    test "fails with a missing content type" do
      res = MockResponse.new
      assert_raises Test::Unit::AssertionFailedError do
        assert_content_type res, "text/html"
      end
    end
  end
end
