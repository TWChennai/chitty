#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.setup

require 'blather/client'
require 'uri'

setup ENV['EMAIL'] || 'thoughtworks.chennai@gmail.com', ENV['PASSWORD']

def say(message)
  log(message)

  player = ENV['PLAYER'] || 'omxplayer'
  max_length = 100
  messages = message.scan(/.{1,#{max_length}}\b|.{1,#{max_length}}/).map(&:strip)

  messages.each do |m|
    url = URI.escape("http://translate.google.com/translate_tts?tl=en&q=#{m}")
    execute %Q{#{player} "#{url}"}
  end
end

def log(message)
  File.open("chitty.log", "a+"){ |f| f << "#{message}\n" }
end

def execute(cmd)
  `#{cmd}`
end

# Auto approve subscription requests
subscription :request? do |s|
  write_to_stream s.approve!
end

# Say what was said
message :chat?, :body do |m|
  message = m.body.gsub("\n", " ").gsub("-", "").gsub("/", " or ")
  message << ".. This message is from: #{m.from.node}"

  say message

  reply = m.reply
  reply.body = "Your wish is my command"
  write_to_stream reply
end

p "Waiting for commands.. Master!!"
