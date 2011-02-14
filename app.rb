#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'rack-flash'
require 'sinatra'

require_relative "lib/settings"
require_relative "lib/site"
require_relative "lib/helpers"
require_relative "lib/actions"

use Rack::Session::Cookie
use Rack::Flash

Settings.set :root, File.expand_path("../", __FILE__)

set :root,             Settings.root
set :site_root,        Settings.root + "/sites"
set :template_root,    Settings.root + "/templates"
set :public,           Proc.new{ puts Settings.public_path; Settings.public_path }
set :views,            Proc.new{ puts Settings.view_path; Settings.view_path }
set :reload_templates, true

include Helpers
include Actions