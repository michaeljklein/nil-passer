require 'minitest/autorun'
require "minitest/reporters"
require 'minitest/color'

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new,
  Minitest::Reporters::SpecReporter.new,
  Minitest::Reporters::ProgressReporter.new,
  Minitest::Reporters::MeanTimeReporter.new
]


require 'simplecov'
require 'codacy-coverage'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    Codacy::Formatter
])

SimpleCov.start do
  add_filter "/test/"
  add_group "Generators", (Dir["lib/gen/**/*.rb"] + ["lib/gen.rb"])
  add_group "Utils", "lib/utils"
end

Codacy::Reporter.start

