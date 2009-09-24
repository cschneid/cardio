Gem::Specification.new do |s|
  s.name = 'cardio'
  s.version = '0.0.1'
  s.summary = %{Deploy checking assertions designed for Test::Unit}
  s.description = %Q{Cardio is a set of Test::Unit assertions designed to run remote web calls against a server, and verify deployments. This includes things like checking gzip, redirects, basic auth, and content.}
  s.authors = ["Christopher Schneider"]
  s.email = ["chris.schneider@citrusbyte.com"]
  s.homepage = "http://github.com/cschneid/cardio"
  s.files = ["lib/cardio.rb", "LICENSE", "Rakefile", "test/assert_test.rb", "test/test_helper.rb"]
  s.rubyforge_project = "cardio"
end
