$:.unshift File.expand_path(File.dirname(__FILE__))

unless defined?(Builder)
  require 'rubygems'
  require 'builder'
end

require 'markaby/builder'
require 'markaby/cssproxy'
require 'markaby/metaid'
require 'markaby/tags'
require 'markaby/template'
