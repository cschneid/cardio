What is it?
============
Cardio is a set of Test::Unit based assertions to test live website deployments
for consistency.  Check that you've setup Passenger and Apache correctly to
redirect, serve pages, and set cache headers.

Cardio is based on Net::HTTP at the moment, but will be expanded
to use other network libraries.


Example:
========

    require 'cardio'
    class Test < Test::Unit::TestCase
      include Cardio::Assertions
      def test_redirect
        res = fetch("http://github.com")
        assert_redirect res, "http://www.github.com"
      end
    end

Or, using my favorite testing library, [Contest](http://labs.citrusbyte.com/projects/contest):

    require 'contest'
    require 'cardio'
    class WebTest < Test::Unit::TestCase
      include Cardio::Assertions
      context "home page" do
        setup do 
          @res = fetch("http://www.github.com")
        end
        test "should be gzipped" do
          assert_gzipped @res
        end
        test "should be cached" do
          assered_cached @res
        end
      end
    end

Assertions:
===========
The res argument is the Net::HTTP response object that is returned by the fetch(url) call.

* assert_gzipped(res)
* assert\_valid_xml(res)
* assert_html(res)
* assert_css(res)
* assert_redirect(res, location)
* assert_code(res, code)
* assert_content(res, content)
* assert\_valid_json(res)
* assert_etag(res)
* assert_cached(res, value=nil)
* assert\_header_present(res, header)
* assert_header(res, header, value)
* assert\_content\_type(res, content_type)
* assert\_in_array(array, item)




Acknowledgments
===============

* keyist for the idea, the name, and everything not involving the actual work to put this together.
* [Citrusbyte](http://www.citrusbyte.com) for being an awesome company to work for


