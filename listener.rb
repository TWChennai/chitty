require 'blather/client/dsl'
require 'uri'

require './gpio'

ENV['EMAIL'] ||= "thoughtworks.chennai@gmail.com"
ENV['PLAYER'] ||= "omxplayer"
ENV['LANGUAGE'] ||= "en"

module Utils
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
    File.open("chitty.log", "a+"){ |f| f << "#{Time.now}: #{message}\n" }
  end

  def execute(cmd)
    `#{cmd}`
  end
end

module Listener
  extend Blather::DSL
  extend Utils

  def self.listen
    p "Started"
    EM.run { client.run }
  end

  setup ENV['EMAIL'], ENV['PASSWORD']

  subscription :request? do |s|
    write_to_stream s.approve!
  end

  message :chat?, :body do |m|
    message = m.body.gsub("\n", " ").gsub("-", "").gsub("/", " or ")

    iq = Blather::Stanza::Iq::Vcard.new :get, "#{m.from.node}@#{m.from.domain}"
    client.write_with_handler iq do |response|
      name = ENV["NAME"] || response.vcard["FN"].split(" ")[0]

      message << ".. This message is brought to you by: #{name}"

      GPIO.on
      say message
      GPIO.off

      reply = m.reply
      reply.body = "Your wish is my command"
      write_to_stream reply
    end
  end
end


trap(:INT) { EM.stop }
trap(:TERM) { EM.stop }
