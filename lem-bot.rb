require 'cinch'
require_relative 'lem-db'

class LemBot
	def initialize
		@db = LemDB.new
	end

	def handle(m=:m, command=:command)
		## Handle our parameters in the worst way possible, str.split
		params = command.split
		if (params[0] == 'remind')
			channel = m.channel.name
			nick = params[1]
			message = params[4..params.length-1].join(' ')

			case params[3]
			when 's', 'seconds'
				remind_at = (Time.now.to_i + params[2].to_i)
			else
				remind_at = (Time.now.to_i + params[2].to_i)
			end

			@db.add_remind(channel, nick, message, remind_at)
			m.reply "Added reminder for #{nick} for #{params[2]} seconds from now."
		end
	end

	def monitor(bot=:bot)
		while true
			reminders = @db.fetch(Time.now.to_i, 2)
			unless reminders.nil?
				reminders.each do |r|
					## Spawn a thread, in case this notification is in the future
					Thread.new {
						while r.remind_at != Time.now.to_i
							sleep(1/2)
						end

						bot.irc.send("PRIVMSG #{r.channel} :<#{r.nick}> #{r.message}")
					}

					## Don't want duplicate reminders!
					r.delete
				end
			end
			sleep(1)
		end
	end
end
