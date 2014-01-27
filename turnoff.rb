#! /usr/bin/env ruby
require 'pi_piper'
include PiPiper

pin = PiPiper::Pin.new(:pin => 17, :direction => :out)
pin.off
	
