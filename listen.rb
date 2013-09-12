#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.setup

require 'blather/client'
require 'uri'

ENV['EMAIL'] ||= "thoughtworks.chennai@gmail.com"
ENV['PLAYER'] ||= "omxplayer"
ENV['LANGUAGE'] ||= "hi"

setup ENV['EMAIL'], ENV['PASSWORD']

def say(message)
  log(message)

  max_length = 100
  messages = message.scan(/.{1,#{max_length}}\b|.{1,#{max_length}}/).map(&:strip)

  messages.each do |m|
    url = URI.escape("http://translate.google.com/translate_tts?tl=#{ENV['LANGUAGE']}&q=#{m}")
    execute %Q{#{ENV['PLAYER']} "#{url}"}
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

  iq = Blather::Stanza::Iq::Vcard.new :get, "#{m.from.node}@#{m.from.domain}"
  client.write_with_handler iq do |response|
    name = ENV["NAME"] || response.vcard["FN"].split(" ")[0]

    message << ".. This message is from: #{name}"
    say message

    reply = m.reply
    reply.body = "Your wish is my command"
    write_to_stream reply
  end
end

p "Waiting for commands.. Master!!"
