$:.unshift File.dirname(__FILE__) unless
  $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'msva/json_request'
require 'msva/mimeparse'
require 'msva/monkeysphere'
require 'msva/opensshpubkey'
require 'msva/server'
