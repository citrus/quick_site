#!/usr/bin/env ruby

$:.unshift File.expand_path("../lib", __FILE__)

require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'rack-flash'

require 'haml'
require 'sinatra'

require "quick_site"

use Rack::Session::Cookie
use Rack::Flash


# quicksite settings
Settings.set :root, File.expand_path("../", __FILE__)
Settings.set(
  :site_root      => Settings.root + "/sites",
  :template_root  => Settings.root + "/templates"
)

# load environment specific config if it exists, otherwise default to standard
unless Settings.load("config/#{settings.environment}.yml")
  Settings.load("config/development.yml")
end


# sinatra settings
set :root,             Settings.root
set :public,           Proc.new{ Settings.public_path }
set :views,            Proc.new{ Settings.view_path }
set :reload_templates, true # force reload for production

include Helpers
include Actions