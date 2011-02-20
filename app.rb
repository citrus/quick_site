#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'rack-flash'

require 'haml'
require 'sinatra'
require 'mustache'

require_relative "lib/settings"
require_relative "lib/site"
require_relative "lib/deployer"
require_relative "lib/helpers"
require_relative "lib/actions"
require_relative "lib/templates"

use Rack::Session::Cookie
use Rack::Flash


# quicksite settings
Settings.set :root, File.expand_path("../", __FILE__)

Settings.set(
  :site_root      => Settings.root + "/sites",
  :template_root  => Settings.root + "/templates",
  :use_git        => true,
  :compress_html  => true,
  :user           => "citrus",
  :host           => "68.6.95.91",
  :port           => 2727,
  :remote_root    => "/home/citrus/domains"
)

# sinatra settings
set :root,             Settings.root
set :public,           Proc.new{ Settings.public_path }
set :views,            Proc.new{ Settings.view_path }
set :reload_templates, true # force reload for production

include Helpers
include Actions