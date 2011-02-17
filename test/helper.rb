ENV["environment"] = "test"

require 'test/unit'
require 'rack/test'
require 'shoulda'

require_relative "../app"