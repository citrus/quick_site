#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'rack-flash'
require 'sinatra'

#require_relative "lib/settings"
require_relative "lib/site"
require_relative "lib/helpers"
require_relative "lib/actions"

use Rack::Session::Cookie
use Rack::Flash

set :root,          File.expand_path("../", __FILE__)
set :site_root,     settings.root + "/sites"
set :template_root, settings.root + "/templates"
set :public,        settings.root + "/public"
set :publik,        settings.root + "/publik"

include Helpers
include Actions