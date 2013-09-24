require 'cinch'
require_relative 'lem-bot'

lem = LemBot.new

bot = Cinch::Bot.new do
	configure do |c|
		c.server = 'irc.freenode.org'
		c.channels = ['#atetracks']
		c.nick = 'lem-bot'
	end

	on :message, /^!(.+)/ do |m, command|
		lem.handle(m, command)
	end
end

Thread.new { lem.monitor(bot) }
bot.start
