require "meer/version"
require 'bundler/setup' 
Bundler.setup(:default)

require 'json'
require 'csv'
require 'thor'
require 'highline/import' 
require 'terminal-table'

module Meer
end

require "meer/datameer"
require "meer/cli"