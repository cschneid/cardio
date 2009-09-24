desc "Generate YARD documentation"
task :doc do
    require "yard"

    opts = ["--protected", "--title", "Cardio -- Deployment Checker"]

    YARD::CLI::Yardoc.run(*opts)
end

desc "Run all tests"
task :test do
  require 'rubygems'
  Dir["test/**/*_test.rb"].each do |file|
    load file
  end
end

