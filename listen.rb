#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.setup

require 'blather/client'
require 'uri'

setup ENV['EMAIL'] || 'thoughtworks.chennai@gmail.com', ENV['PASSWORD']

def say(message)
  player = ENV['PLAYER'] || 'omxplayer'
  url = URI.escape("http://translate.google.com/translate_tts?tl=en&q=#{message}")
  `#{player} "#{url}"`
end

# Auto approve subscription requests
subscription :request? do |s|
  write_to_stream s.approve!
end

# Say what was said
message :chat?, :body do |m|
  say m.body
  say "This message is from: #{m.from.node}"
  reply = m.reply
  reply.body = "Your wish is my command"
  write_to_stream reply
end

p "Waiting for commands.. Master!!"
