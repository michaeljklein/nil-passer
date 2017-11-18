require 'minitest/autorun'
require "minitest/reporters"
require 'minitest/color'

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new,
  Minitest::Reporters::SpecReporter.new,
  Minitest::Reporters::ProgressReporter.new,
  Minitest::Reporters::MeanTimeReporter.new
]
